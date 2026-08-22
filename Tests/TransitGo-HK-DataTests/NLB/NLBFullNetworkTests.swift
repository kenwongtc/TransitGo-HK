//
//  NLBFullNetworkTests.swift
//  TransitGo-HK
//

import XCTest
@testable import TransitGo_HK_Data

final class NLBFullNetworkTests: XCTestCase {

    func testBuildFullNLBNetwork() async throws {

        let outputDirectory = URL(
            fileURLWithPath:
                FileManager.default
                    .currentDirectoryPath
        )
        .appendingPathComponent("Output")

        let routes: [Route] = try decode(
            [Route].self,
            filename: "routes.json",
            directory: outputDirectory
        )

        let journeys: [Journey] = try decode(
            [Journey].self,
            filename: "journeys.json",
            directory: outputDirectory
        )

        let journeyStops: [JourneyStop] = try decode(
            [JourneyStop].self,
            filename: "journey_stops.json",
            directory: outputDirectory
        )

        let stops: [Stop] = try decode(
            [Stop].self,
            filename: "stops.json",
            directory: outputDirectory
        )

        let result =
            try await NLBOperatorStopReferenceBuilder()
                .buildAll(
                    routes: routes,
                    journeys: journeys,
                    journeyStops: journeyStops,
                    stops: stops
                )

        print("")
        print("*** NLB full-network result ***")
        print("References:", result.references.count)
        print("Matched journeys:", result.matchedJourneys)
        print("Unmatched routes:", result.unmatchedRoutes.count)
        print("Unmatched journeys:", result.unmatchedJourneys.count)
        print("Ambiguous journeys:", result.ambiguousJourneys.count)
        print("Rejected journeys:", result.rejectedJourneys.count)

        let unresolvedJourneys =
            result.unmatchedJourneys.map {
                ($0, "UNMATCHED")
            } +
            result.ambiguousJourneys.map {
                ($0, "AMBIGUOUS")
            } +
            result.rejectedJourneys.map {
                ($0, "REJECTED")
            }

        if !unresolvedJourneys.isEmpty {

            let routeLookup = Dictionary(
                uniqueKeysWithValues:
                    routes.map {
                        ($0.id, $0)
                    }
            )

            let journeyLookup = Dictionary(
                uniqueKeysWithValues:
                    journeys.map {
                        ($0.id, $0)
                    }
            )

            print("")
            print("*** Unresolved NLB journeys ***")

            for (journeyId, reason) in
                unresolvedJourneys.sorted(by: {
                    $0.0 < $1.0
                }) {

                guard
                    let journey =
                        journeyLookup[journeyId],
                    let route =
                        routeLookup[journey.routeId]
                else {
                    print(journeyId)
                    continue
                }

                print(
                    reason,
                    "|",
                    journey.id,
                    "| route:", route.number,
                    "|", route.originEnglish,
                    "→", route.destinationEnglish,
                    "| direction:", journey.direction,
                    "| service:", journey.serviceType
                )
            }
        }

        XCTAssertFalse(result.references.isEmpty)
        XCTAssertGreaterThan(result.matchedJourneys, 0)

        XCTAssertTrue(
            result.references.allSatisfy {
                $0.operatorId == "NLB" &&
                !$0.operatorStopId.isEmpty &&
                !$0.operatorServiceType.isEmpty
            }
        )
    }

    private func decode<T: Decodable>(
        _ type: T.Type,
        filename: String,
        directory: URL
    ) throws -> T {

        let data = try Data(
            contentsOf:
                directory.appendingPathComponent(
                    filename
                )
        )

        return try JSONDecoder().decode(
            type,
            from: data
        )
    }
}
