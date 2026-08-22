//
//  CSDIJourneyShapeIntegrationTests.swift
//  TransitGo-HK
//

import Foundation
import XCTest
@testable import TransitGo_HK_Data

final class CSDIJourneyShapeIntegrationTests:
    XCTestCase {

    func testBuildsRealJourneyShapes() async throws {

        let datasetDirectory = URL(
            fileURLWithPath:
                FileManager.default.currentDirectoryPath
        )
        .appendingPathComponent("Dataset")

        let journeys: [Journey] = try JSONDecoder()
            .decode(
                [Journey].self,
                from: Data(
                    contentsOf:
                        datasetDirectory
                            .appendingPathComponent(
                                "journeys.json"
                            )
                )
            )

        let officialShapes = try await
            CSDIBusRouteShapeReader().fetch()
        let journeyShapes = JourneyShapeBuilder()
            .build(
                journeys: journeys,
                officialShapes: officialShapes
            )
        let encoded = try JSONEncoder().encode(
            journeyShapes
        )

        let coordinateCount = journeyShapes.reduce(0) {
            $0 + $1.coordinates.count
        }

        print("")
        print("*** Real CSDI journey shapes ***")
        print("Official features:", officialShapes.count)
        print("Matched journeys:", journeyShapes.count)
        print("Coordinates:", coordinateCount)
        print("Encoded bytes:", encoded.count)

        XCTAssertEqual(officialShapes.count, 2_255)
        XCTAssertFalse(journeyShapes.isEmpty)
        XCTAssertTrue(
            journeyShapes.allSatisfy {
                $0.coordinates.count >= 2
            }
        )
        XCTAssertNotNil(
            journeyShapes.first {
                $0.journeyId == "1001-1"
            }
        )
    }
}
