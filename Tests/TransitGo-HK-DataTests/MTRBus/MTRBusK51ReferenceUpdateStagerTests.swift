//
//  MTRBusK51ReferenceUpdateStagerTests.swift
//  TransitGo-HK
//

import Foundation
import XCTest
@testable import TransitGo_HK_Data

final class MTRBusK51ReferenceUpdateStagerTests:
    XCTestCase {

    func testStagesK51AndIncrementsSameDayVersion()
        throws {

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
                from: "2026-08-22T02:00:00Z"
            )
        )

        let result = try stager.stage(
            existingReferences: [],
            replacementK51References: [
                reference
            ],
            currentVersion: DataVersion(
                version: "2026.08.22",
                generatedAt:
                    "2026-08-22T00:00:00Z"
            ),
            to: directory,
            generatedAt: generatedAt
        )

        XCTAssertEqual(
            result.version.version,
            "2026.08.22.1"
        )
        XCTAssertEqual(result.referenceCount, 1)
        XCTAssertEqual(result.k51ReferenceCount, 1)

        let decoded: [OperatorStopReference] =
            try decode(
                "operator_stop_references.json",
                from: directory
            )
        let metadata: DataVersion = try decode(
            "dataset_info.json",
            from: directory
        )

        XCTAssertEqual(decoded.count, 1)
        XCTAssertEqual(
            metadata.version,
            "2026.08.22.1"
        )
    }

    private let stager =
        MTRBusK51ReferenceUpdateStager()

    private let reference = OperatorStopReference(
        operatorId: "LRTFeeder",
        journeyId: "1871-1",
        stopId: "stop",
        sequence: 1,
        operatorStopId: "K51-D010",
        operatorServiceType: "K51",
        operatorDirection: "O"
    )

    private func decode<T: Decodable>(
        _ filename: String,
        from directory: URL
    ) throws -> T {

        try JSONDecoder().decode(
            T.self,
            from: Data(
                contentsOf:
                    directory.appendingPathComponent(
                        filename
                    )
            )
        )
    }
}
