//
//  MTRBusOperatorStopReferenceBuilder.swift
//  TransitGo-HK
//

import Foundation

struct MTRBusOperatorStopReferenceBuildResult {

    let references: [OperatorStopReference]
    let direction: String
    let coverage: Double
    let averageDistanceMeters: Double
}

struct MTRBusOperatorStopReferenceBuilder {

    private let aligner =
        MTRBusStopSequenceAligner()

    func buildK51(
        routes: [Route],
        journeys: [Journey],
        journeyStops: [JourneyStop],
        stops: [Stop]
    ) async throws
        -> [MTRBusOperatorStopReferenceBuildResult] {

        let officialStops = try await
            MTRBusStopCSVReader().fetch()

        return buildK51(
            routes: routes,
            journeys: journeys,
            journeyStops: journeyStops,
            stops: stops,
            officialStops: officialStops
        )
    }

    func buildK51(
        routes: [Route],
        journeys: [Journey],
        journeyStops: [JourneyStop],
        stops: [Stop],
        officialStops: [MTRBusStopRecord]
    ) -> [MTRBusOperatorStopReferenceBuildResult] {

        let k51Routes = routes.filter {
            $0.supportsOperator("LRTFeeder") &&
            $0.number.caseInsensitiveCompare(
                "K51"
            ) == .orderedSame &&
            $0.originEnglish == "Fu Tai" &&
            $0.destinationEnglish == "Tai Lam"
        }

        let officialK51Stops = officialStops.filter {
            $0.routeId == "K51" &&
            $0.referenceId == "K51"
        }

        let candidatesByDirection = Dictionary(
            grouping: officialK51Stops,
            by: \.direction
        )

        let stopLookup = Dictionary(
            uniqueKeysWithValues:
                stops.map { ($0.id, $0) }
        )

        var results:
            [MTRBusOperatorStopReferenceBuildResult] = []

        for route in k51Routes {
            let routeJourneys = journeys.filter {
                $0.routeId == route.id
            }

            for journey in routeJourneys {
                let localStops = journeyStops.filter {
                    $0.journeyId == journey.id
                }

                let candidates = candidatesByDirection.map {
                    direction,
                    officialDirectionStops in

                    MTRBusCandidate(
                        direction: direction,
                        alignment: aligner.align(
                            transitGoStops: localStops,
                            mtrBusStops:
                                officialDirectionStops,
                            localStopLookup:
                                stopLookup
                        )
                    )
                }
                .sorted(by: ranksBefore)

                guard
                    let winner = candidates.first,
                    winner.alignment
                        .transitGoCoverage >= 0.75,
                    winner.alignment
                        .matchedPairs.count >= 2
                else {
                    continue
                }

                let references = winner.alignment
                    .matchedPairs
                    .map { pair in
                        OperatorStopReference(
                            operatorId: "LRTFeeder",
                            journeyId: journey.id,
                            stopId:
                                pair.transitGoStop.stopId,
                            sequence:
                                pair.transitGoStop.sequence,
                            operatorStopId:
                                pair.mtrBusStop.stopId,
                            operatorServiceType: "K51",
                            operatorDirection:
                                winner.direction
                        )
                    }
                    .sorted {
                        $0.sequence < $1.sequence
                    }

                results.append(
                    MTRBusOperatorStopReferenceBuildResult(
                        references: references,
                        direction: winner.direction,
                        coverage: winner.alignment
                            .transitGoCoverage,
                        averageDistanceMeters:
                            winner.alignment
                                .averageDistanceMeters ??
                                .infinity
                    )
                )
            }
        }

        return results.sorted {
            ($0.references.first?.journeyId ?? "") <
                ($1.references.first?.journeyId ?? "")
        }
    }

    private func ranksBefore(
        _ lhs: MTRBusCandidate,
        _ rhs: MTRBusCandidate
    ) -> Bool {

        if lhs.alignment.transitGoCoverage !=
            rhs.alignment.transitGoCoverage {
            return lhs.alignment.transitGoCoverage >
                rhs.alignment.transitGoCoverage
        }

        if lhs.alignment.matchedPairs.count !=
            rhs.alignment.matchedPairs.count {
            return lhs.alignment.matchedPairs.count >
                rhs.alignment.matchedPairs.count
        }

        return (lhs.alignment.averageDistanceMeters ??
            .infinity) <
            (rhs.alignment.averageDistanceMeters ??
                .infinity)
    }
}

private struct MTRBusCandidate {
    let direction: String
    let alignment: MTRBusStopSequenceAlignment
}
