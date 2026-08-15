//
//  CTBOperatorStopReferenceBuilderTests.swift
//  TransitGo-HK
//
//  Created by Ken on 15/8/2026.
//

import XCTest
@testable import TransitGo_HK_Data

final class CTBOperatorStopReferenceBuilderTests: XCTestCase {

    func testBuildSingleCTBJourney() async throws {

        print("")
        print("1. Loading existing Output JSON")

        let outputDirectory =
            URL(
                fileURLWithPath:
                    FileManager.default.currentDirectoryPath
            )
            .appendingPathComponent(
                "Output"
            )

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

        // -----------------------------------
        // Diagnostic target
        // -----------------------------------

        let routeId =
            "1616"

        let journeyId =
            "1616-1"

        guard let route =
            routes.first(where: {
                $0.id == routeId
            })
        else {

            XCTFail(
                "Route \(routeId) not found"
            )

            return
        }

        guard let journey =
            journeys.first(where: {
                $0.id == journeyId
            })
        else {

            XCTFail(
                "Journey \(journeyId) not found"
            )

            return
        }

        print("")
        print("3. Starting CTB builder")
        print(
            "Route ID:",
            routeId
        )
        print(
            "Journey ID:",
            journeyId
        )

        let start =
            Date()

        let references =
            try await
                CTBOperatorStopReferenceBuilder()
                    .build(
                        route:
                            route,
                        journey:
                            journey,
                        journeyStops:
                            journeyStops,
                        stops:
                            stops
                    )

        let elapsed =
            Date()
                .timeIntervalSince(
                    start
                )

        print("")
        print("4. CTB builder finished")

        print("")
        print("*** CTB references ***")

        print(
            "References:",
            references.count
        )

        print(
            "Elapsed:",
            String(
                format:
                    "%.1f seconds",
                elapsed
            )
        )

        for reference in references {

            print(
                "seq:",
                reference.sequence,
                "| TransitGo:",
                reference.stopId,
                "| CTB:",
                reference.operatorStopId
            )
        }

        XCTAssertFalse(
            references.isEmpty
        )

        XCTAssertTrue(
            references.allSatisfy {
                $0.operatorId == "CTB"
            }
        )
    }

    // MARK: - JSON

    private func decode<T: Decodable>(
        _ type: T.Type,
        from url: URL
    ) throws -> T {

        let data =
            try Data(
                contentsOf:
                    url
            )

        return try JSONDecoder()
            .decode(
                type,
                from:
                    data
            )
    }
}
