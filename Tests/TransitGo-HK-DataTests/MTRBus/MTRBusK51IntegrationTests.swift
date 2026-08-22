//
//  MTRBusK51IntegrationTests.swift
//  TransitGo-HK
//

import Foundation
import XCTest
@testable import TransitGo_HK_Data

final class MTRBusK51IntegrationTests:
    XCTestCase {

    func testBuildsRealMTRBusNetwork()
        async throws {

        let datasetDirectory = URL(
            fileURLWithPath:
                FileManager.default.currentDirectoryPath
        )
        .appendingPathComponent("Dataset")

        let routes: [Route] = try decode(
            "routes.json",
            from: datasetDirectory
        )
        let journeys: [Journey] = try decode(
            "journeys.json",
            from: datasetDirectory
        )
        let journeyStops: [JourneyStop] = try decode(
            "journey_stops.json",
            from: datasetDirectory
        )
        let stops: [Stop] = try decode(
            "stops.json",
            from: datasetDirectory
        )

        let results = try await
            MTRBusOperatorStopReferenceBuilder()
                .buildAll(
                    routes: routes,
                    journeys: journeys,
                    journeyStops: journeyStops,
                    stops: stops
                )

        let groupedResults = Dictionary(
            grouping: results,
            by: \.routeNumber
        )

        print("")
        print("*** Real MTR Bus network build ***")

        for routeNumber in groupedResults.keys.sorted() {
            let routeResults = groupedResults[
                routeNumber,
                default: []
            ]
            let references = routeResults
                .flatMap(\.references)

            print(
                routeNumber,
                "| journeys:", routeResults.count,
                "| references:", references.count,
                "| minimum coverage:",
                routeResults.map(\.coverage).min() ?? 0
            )
        }

        let acceptedJourneyIds = Set(
            results.compactMap {
                $0.references.first?.journeyId
            }
        )
        let localMTRRouteNumbers = Set(
            routes
                .filter {
                    $0.supportsOperator("LRTFeeder")
                }
                .map(\.number)
        )
        let officialStops = try await
            MTRBusStopCSVReader().fetch()
        let officialRouteNumbers = Set(
            officialStops.map(\.routeId)
        )
        let commonRouteNumbers =
            localMTRRouteNumbers
                .intersection(officialRouteNumbers)
                .sorted()
        let stopLookup = Dictionary(
            uniqueKeysWithValues:
                stops.map { ($0.id, $0) }
        )

        for routeNumber in commonRouteNumbers {
            let localRouteIds = Set(
                routes
                    .filter {
                        $0.supportsOperator(
                            "LRTFeeder"
                        ) &&
                        $0.number == routeNumber
                    }
                    .map(\.id)
            )
            let routeJourneys = journeys.filter {
                localRouteIds.contains($0.routeId) &&
                !acceptedJourneyIds.contains($0.id)
            }

            guard !routeJourneys.isEmpty else {
                continue
            }

            print("Rejected journeys for:", routeNumber)
            let candidateGroups = Dictionary(
                grouping: officialStops.filter {
                    $0.routeId == routeNumber
                },
                by: {
                    "\($0.referenceId)|\($0.direction)"
                }
            )

            for journey in routeJourneys {
                let localStops = journeyStops.filter {
                    $0.journeyId == journey.id
                }
                let candidates = candidateGroups.map {
                    key,
                    remoteStops in

                    (
                        key,
                        MTRBusStopSequenceAligner()
                            .align(
                                transitGoStops:
                                    localStops,
                                mtrBusStops:
                                    remoteStops,
                                localStopLookup:
                                    stopLookup
                            )
                    )
                }
                let best = candidates.max {
                    $0.1.transitGoCoverage <
                        $1.1.transitGoCoverage
                }

                print(
                    "  journey:", journey.id,
                    "| candidate:", best?.0 ?? "none",
                    "| matched:",
                    best?.1.matchedPairs.count ?? 0,
                    "/", localStops.count,
                    "| coverage:",
                    best?.1.transitGoCoverage ?? 0,
                    "| average distance:",
                    best?.1.averageDistanceMeters ?? -1
                )

                if let alignment = best?.1 {
                    print("    unmatched local:")
                    for item in alignment.transitGoOnly {
                        print(
                            "     ", item.sequence,
                            stopLookup[item.stopId]?
                                .nameEnglish ?? "unknown"
                        )
                    }
                    print("    unmatched official:")
                    for item in alignment.mtrBusOnly {
                        print(
                            "     ", item.sequence,
                            item.nameEnglish
                        )
                    }
                }
            }
        }

        XCTAssertTrue(
            groupedResults.keys.count == 22
        )
        XCTAssertEqual(
            acceptedJourneyIds.count,
            45
        )
        XCTAssertTrue(
            results.allSatisfy {
                $0.coverage >= 0.55 &&
                $0.averageDistanceMeters <= 350 &&
                !$0.references.isEmpty
            }
        )
    }

    func testBuildsAllRealK51Journeys()
        async throws {

        let outputDirectory = URL(
            fileURLWithPath:
                FileManager.default
                    .currentDirectoryPath
        )
        .appendingPathComponent("Output")

        let routes: [Route] = try decode(
            "routes.json",
            from: outputDirectory
        )
        let journeys: [Journey] = try decode(
            "journeys.json",
            from: outputDirectory
        )
        let journeyStops: [JourneyStop] = try decode(
            "journey_stops.json",
            from: outputDirectory
        )
        let stops: [Stop] = try decode(
            "stops.json",
            from: outputDirectory
        )

        let results = try await
            MTRBusOperatorStopReferenceBuilder()
                .build(
                    routeNumber: "K51",
                    routes: routes,
                    journeys: journeys,
                    journeyStops: journeyStops,
                    stops: stops
                )

        print("")
        print("*** Real K51 reference build ***")

        for result in results {
            print(
                result.references.first?.journeyId ??
                    "unknown",
                "| direction:", result.direction,
                "| references:", result.references.count,
                "| coverage:", result.coverage,
                "| average distance:",
                result.averageDistanceMeters
            )
        }

        if results.count < 2,
           let reverseJourney = journeys.first(
            where: { $0.id == "1871-2" }
           ) {

            let officialStops = try await
                MTRBusStopCSVReader().fetch()
                .filter {
                    $0.routeId == "K51" &&
                    $0.referenceId == "K51"
                }

            let stopLookup = Dictionary(
                uniqueKeysWithValues:
                    stops.map { ($0.id, $0) }
            )

            let reverseStops = journeyStops.filter {
                $0.journeyId == reverseJourney.id
            }

            for (direction, remoteStops) in Dictionary(
                grouping: officialStops,
                by: \.direction
            ) {
                let alignment =
                    MTRBusStopSequenceAligner().align(
                        transitGoStops: reverseStops,
                        mtrBusStops: remoteStops,
                        localStopLookup: stopLookup
                    )

                print(
                    "1871-2 candidate",
                    direction,
                    "| matched:",
                    alignment.matchedPairs.count,
                    "/", reverseStops.count,
                    "| coverage:",
                    alignment.transitGoCoverage
                )

                for item in alignment.transitGoOnly {
                    print(
                        "unmatched:",
                        item.sequence,
                        stopLookup[item.stopId]?
                            .nameEnglish ?? "unknown"
                    )
                }

                for item in alignment.mtrBusOnly {
                    print(
                        "unmatched official:",
                        item.sequence,
                        item.nameEnglish
                    )
                }
            }
        }

        XCTAssertEqual(results.count, 3)
        XCTAssertEqual(
            results.compactMap {
                $0.references.first?.journeyId
            },
            ["1000657-1", "1871-1", "1871-2"]
        )
        XCTAssertTrue(
            results.allSatisfy {
                $0.coverage >= 0.75 &&
                !$0.references.isEmpty
            }
        )
        XCTAssertTrue(
            results.flatMap(\.references)
                .allSatisfy {
                    $0.operatorId == "LRTFeeder" &&
                    $0.operatorServiceType == "K51" &&
                    !$0.operatorStopId.isEmpty
                }
        )
    }

    func testAlignsRealK51FuTaiToTaiLamJourney()
        async throws {

        let outputDirectory = URL(
            fileURLWithPath:
                FileManager.default
                    .currentDirectoryPath
        )
        .appendingPathComponent("Output")

        let routes: [Route] = try decode(
            "routes.json",
            from: outputDirectory
        )
        let journeys: [Journey] = try decode(
            "journeys.json",
            from: outputDirectory
        )
        let journeyStops: [JourneyStop] = try decode(
            "journey_stops.json",
            from: outputDirectory
        )
        let stops: [Stop] = try decode(
            "stops.json",
            from: outputDirectory
        )

        let route = try XCTUnwrap(
            routes.first {
                $0.number == "K51" &&
                $0.originEnglish == "Fu Tai" &&
                $0.destinationEnglish == "Tai Lam"
            }
        )

        let journey = try XCTUnwrap(
            journeys.first {
                $0.routeId == route.id &&
                $0.direction == "1"
            }
        )

        let localJourneyStops = journeyStops.filter {
            $0.journeyId == journey.id
        }

        let officialStops = try await
            MTRBusStopCSVReader().fetch()
            .filter {
                $0.routeId == "K51" &&
                $0.referenceId == "K51"
            }

        let officialStopsByDirection = Dictionary(
            grouping: officialStops,
            by: \.direction
        )

        let stopLookup = Dictionary(
            uniqueKeysWithValues:
                stops.map { ($0.id, $0) }
        )

        let candidates = officialStopsByDirection.map {
            direction,
            stops in

            (
                direction,
                MTRBusStopSequenceAligner().align(
                    transitGoStops: localJourneyStops,
                    mtrBusStops: stops,
                    localStopLookup: stopLookup
                )
            )
        }

        let best = try XCTUnwrap(
            candidates.max {
                lhs,
                rhs in

                if lhs.1.transitGoCoverage !=
                    rhs.1.transitGoCoverage {
                    return lhs.1.transitGoCoverage <
                        rhs.1.transitGoCoverage
                }

                return (lhs.1.averageDistanceMeters ??
                    .infinity) >
                    (rhs.1.averageDistanceMeters ??
                        .infinity)
            }
        )

        print("")
        print("*** Real K51 alignment ***")
        print("Journey:", journey.id)
        print("Official direction:", best.0)
        print(
            "Matched:",
            best.1.matchedPairs.count,
            "/",
            localJourneyStops.count
        )
        print("Coverage:", best.1.transitGoCoverage)
        print(
            "Average distance:",
            best.1.averageDistanceMeters ?? -1
        )

        print("Unmatched local stops:")
        for journeyStop in best.1.transitGoOnly {
            let stop = stopLookup[journeyStop.stopId]
            print(
                journeyStop.sequence,
                journeyStop.stopId,
                stop?.nameEnglish ?? "unknown",
                stop?.latitude ?? 0,
                stop?.longitude ?? 0
            )
        }

        print("Largest matched distances:")
        for match in best.1.matchedPairs
            .sorted(by: {
                $0.distanceMeters >
                    $1.distanceMeters
            })
            .prefix(10) {

            let localStop = stopLookup[
                match.transitGoStop.stopId
            ]

            print(
                match.transitGoStop.sequence,
                localStop?.nameEnglish ?? "unknown",
                "→",
                match.mtrBusStop.sequence,
                match.mtrBusStop.nameEnglish,
                "|",
                match.distanceMeters
            )
        }

        XCTAssertGreaterThanOrEqual(
            best.1.transitGoCoverage,
            0.9
        )
        XCTAssertLessThan(
            best.1.averageDistanceMeters ??
                .infinity,
            400
        )
    }

    private func decode<T: Decodable>(
        _ filename: String,
        from directory: URL
    ) throws -> T {

        let data = try Data(
            contentsOf:
                directory.appendingPathComponent(
                    filename
                )
        )

        return try JSONDecoder().decode(
            T.self,
            from: data
        )
    }
}
