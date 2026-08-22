//
//  NLBReferenceUpdateStagerTests.swift
//  TransitGo-HK
//

import XCTest
@testable import TransitGo_HK_Data

final class NLBReferenceUpdateStagerTests:
    XCTestCase {

    func testStagesMergedReferencesAndVersion()
        throws {

        let directory =
            FileManager.default.temporaryDirectory
                .appendingPathComponent(
                    UUID().uuidString
                )

        defer {
            try? FileManager.default
                .removeItem(at: directory)
        }

        let generatedAt = Date(
            timeIntervalSince1970: 1_775_865_600
        )

        let result = try stager.stage(
            existingReferences: [
                reference(
                    operatorId: "KMB",
                    journeyId: "kmb"
                ),
                reference(
                    operatorId: "NLB",
                    journeyId: "old-nlb"
                )
            ],
            replacementNLBReferences: [
                reference(
                    operatorId: "NLB",
                    journeyId: "new-nlb"
                )
            ],
            to: directory,
            generatedAt: generatedAt
        )

        let references: [OperatorStopReference] =
            try decode(
                [OperatorStopReference].self,
                from: directory
                    .appendingPathComponent(
                        "operator_stop_references.json"
                    )
            )

        let version: DataVersion = try decode(
            DataVersion.self,
            from: directory.appendingPathComponent(
                "dataset_info.json"
            )
        )

        XCTAssertEqual(result.referenceCount, 2)
        XCTAssertEqual(result.nlbReferenceCount, 1)
        XCTAssertEqual(references.count, 2)
        XCTAssertTrue(
            references.contains {
                $0.journeyId == "new-nlb"
            }
        )
        XCTAssertFalse(
            references.contains {
                $0.journeyId == "old-nlb"
            }
        )
        XCTAssertEqual(
            version.version,
            result.version.version
        )
        XCTAssertEqual(
            version.generatedAt,
            result.version.generatedAt
        )
    }

    private let stager =
        NLBReferenceUpdateStager()

    private func reference(
        operatorId: String,
        journeyId: String
    ) -> OperatorStopReference {

        OperatorStopReference(
            operatorId: operatorId,
            journeyId: journeyId,
            stopId: "stop",
            sequence: 1,
            operatorStopId: "operator-stop",
            operatorServiceType: "service",
            operatorDirection: "direction"
        )
    }

    private func decode<T: Decodable>(
        _ type: T.Type,
        from url: URL
    ) throws -> T {

        try JSONDecoder().decode(
            type,
            from: Data(contentsOf: url)
        )
    }
}
