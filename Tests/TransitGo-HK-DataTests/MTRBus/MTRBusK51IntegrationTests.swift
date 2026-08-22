//
//  MTRBusK51IntegrationTests.swift
//  TransitGo-HK
//

import Foundation
import XCTest
@testable import TransitGo_HK_Data

final class MTRBusK51IntegrationTests:
    XCTestCase {

    func testBuildsBothRealK51Directions()
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
                .buildK51(
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

        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(
            results.compactMap {
                $0.references.first?.journeyId
            },
            ["1871-1", "1871-2"]
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
