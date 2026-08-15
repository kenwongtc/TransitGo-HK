//
//  CTBFullNetworkTests.swift
//  TransitGo-HK
//
//  Created by Ken on 15/8/2026.
//

import XCTest
@testable import TransitGo_HK_Data

final class CTBFullNetworkTests: XCTestCase {

    func testBuildFullCTBNetwork() async throws {

        print("")
        print("1. Loading existing Output JSON")

        let outputDirectory =
            URL(fileURLWithPath:
                FileManager.default.currentDirectoryPath
            )
            .appendingPathComponent("Output")

        let routes: [Route] =
            try decode(
                [Route].self,
                from:
                    outputDirectory
                        .appendingPathComponent(
                            "routes.json"
                        )
            )

        let journeys: [Journey] =
            try decode(
                [Journey].self,
                from:
                    outputDirectory
                        .appendingPathComponent(
                            "journeys.json"
                        )
            )

        let journeyStops: [JourneyStop] =
            try decode(
                [JourneyStop].self,
                from:
                    outputDirectory
                        .appendingPathComponent(
                            "journey_stops.json"
                        )
            )

        let stops: [Stop] =
            try decode(
                [Stop].self,
                from:
                    outputDirectory
                        .appendingPathComponent(
                            "stops.json"
                        )
            )

        print("2. Existing master data loaded")

        let ctbRoutes =
            routes.filter {
                $0.operatorIds.contains("CTB")
            }

        let ctbRouteIds =
            Set(
                ctbRoutes.map(\.id)
            )

        let ctbJourneys =
            journeys.filter {
                ctbRouteIds.contains(
                    $0.routeId
                )
            }

        print("")
        print("*** CTB input ***")
        print(
            "Routes:",
            ctbRoutes.count
        )
        print(
            "Journeys:",
            ctbJourneys.count
        )
        print(
            "Journey stops:",
            journeyStops.count
        )
        print(
            "Stops:",
            stops.count
        )

        print("")
        print("3. Starting CTB full-network builder")

        let start =
            Date()

        let result =
            try await CTBOperatorStopReferenceBuilder()
                .buildAll(
                    routes:
                        routes,
                    journeys:
                        journeys,
                    journeyStops:
                        journeyStops,
                    stops:
                        stops
                )

        let elapsed =
            Date().timeIntervalSince(
                start
            )

        print("")
        print("4. CTB full-network builder finished")

        print("")
        print("*** CTB full-network result ***")

        print(
            "References:",
            result.references.count
        )

        print(
            "Matched journeys:",
            result.matchedJourneys
        )

        print(
            "Unmatched routes:",
            result.unmatchedRoutes.count
        )

        print(
            "Unmatched journeys:",
            result.unmatchedJourneys.count
        )

        print(
            "Ambiguous journeys:",
            result.ambiguousJourneys.count
        )

        print(
            "Rejected journeys:",
            result.rejectedJourneys.count
        )

        print(
            "Elapsed:",
            String(
                format: "%.1f seconds",
                elapsed
            )
        )

        if !result.unmatchedRoutes.isEmpty {

            print("")
            print("*** Unmatched CTB routes ***")

            for item in result.unmatchedRoutes {
                print(item)
            }
        }

        if !result.unmatchedJourneys.isEmpty {

            print("")
            print("*** Unmatched CTB journeys ***")

            for item in result.unmatchedJourneys {
                print(item)
            }
        }

        if !result.ambiguousJourneys.isEmpty {

            print("")
            print("*** Ambiguous CTB journeys ***")

            for item in result.ambiguousJourneys {
                print(item)
            }
        }

        if !result.rejectedJourneys.isEmpty {

            print("")
            print("*** Rejected CTB journeys ***")

            for item in result.rejectedJourneys {
                print(item)
            }
        }

        XCTAssertGreaterThan(
            result.references.count,
            0
        )

        XCTAssertGreaterThan(
            result.matchedJourneys,
            0
        )
    }

    // MARK: - JSON

    private func decode<T: Decodable>(
        _ type: T.Type,
        from url: URL
    ) throws -> T {

        let data =
            try Data(
                contentsOf: url
            )

        return try JSONDecoder()
            .decode(
                type,
                from: data
            )
    }
}
