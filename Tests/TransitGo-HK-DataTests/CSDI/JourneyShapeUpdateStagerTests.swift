//
//  JourneyShapeUpdateStagerTests.swift
//  TransitGo-HK
//

import Foundation
import XCTest
@testable import TransitGo_HK_Data

final class JourneyShapeUpdateStagerTests:
    XCTestCase {

    func testStagesCompactShapesAndVersion() throws {

        let directory = FileManager.default
            .temporaryDirectory
            .appendingPathComponent(UUID().uuidString)

        defer {
            try? FileManager.default.removeItem(
                at: directory
            )
        }

        let generatedAt = try XCTUnwrap(
            ISO8601DateFormatter().date(
                from: "2026-08-22T03:00:00Z"
            )
        )
        let shapes = [
            JourneyShape(
                journeyId: "1001-1",
                coordinates: [
                    JourneyShapeCoordinate(
                        latitude: 22.2,
                        longitude: 114.1
                    ),
                    JourneyShapeCoordinate(
                        latitude: 22.3,
                        longitude: 114.2
                    )
                ]
            )
        ]

        let result = try stager.stage(
            shapes: shapes,
            currentVersion: DataVersion(
                version: "2026.08.22.2",
                generatedAt:
                    "2026-08-22T02:00:00Z"
            ),
            to: directory,
            generatedAt: generatedAt
        )

        XCTAssertEqual(result.shapeCount, 1)
        XCTAssertEqual(result.coordinateCount, 2)
        XCTAssertEqual(
            result.version.version,
            "2026.08.22.3"
        )

        let decoded = try JSONDecoder().decode(
            [JourneyShape].self,
            from: Data(
                contentsOf:
                    directory.appendingPathComponent(
                        "journey_shapes.json"
                    )
            )
        )

        XCTAssertEqual(decoded.count, 1)
        XCTAssertEqual(
            decoded[0].coordinates,
            shapes[0].coordinates
        )
    }

    private let stager = JourneyShapeUpdateStager()
}
