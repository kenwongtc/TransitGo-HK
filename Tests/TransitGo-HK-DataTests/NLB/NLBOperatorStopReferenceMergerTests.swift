//
//  NLBOperatorStopReferenceMergerTests.swift
//  TransitGo-HK
//

import XCTest
@testable import TransitGo_HK_Data

final class NLBOperatorStopReferenceMergerTests:
    XCTestCase {

    func testReplacesNLBAndPreservesOtherOperators()
        throws {

        let existing = [
            reference(
                operatorId: "KMB",
                journeyId: "kmb-journey"
            ),
            reference(
                operatorId: "NLB",
                journeyId: "old-nlb"
            ),
            reference(
                operatorId: "CTB",
                journeyId: "ctb-journey"
            )
        ]

        let replacement = [
            reference(
                operatorId: "NLB",
                journeyId: "new-nlb"
            )
        ]

        let merged = try merger.merge(
            existing: existing,
            replacementNLBReferences:
                replacement
        )

        XCTAssertEqual(merged.count, 3)
        XCTAssertFalse(
            merged.contains {
                $0.journeyId == "old-nlb"
            }
        )
        XCTAssertTrue(
            merged.contains {
                $0.journeyId == "new-nlb"
            }
        )
        XCTAssertTrue(
            merged.contains {
                $0.operatorId == "KMB"
            }
        )
        XCTAssertTrue(
            merged.contains {
                $0.operatorId == "CTB"
            }
        )
        XCTAssertEqual(
            merged.map(\.journeyId),
            [
                "kmb-journey",
                "ctb-journey",
                "new-nlb"
            ]
        )
    }

    func testRejectsNonNLBReplacement() {

        XCTAssertThrowsError(
            try merger.merge(
                existing: [],
                replacementNLBReferences: [
                    reference(
                        operatorId: "KMB",
                        journeyId: "journey"
                    )
                ]
            )
        )
    }

    func testRejectsDuplicateReferenceKey() {

        let duplicate = reference(
            operatorId: "NLB",
            journeyId: "journey"
        )

        XCTAssertThrowsError(
            try merger.merge(
                existing: [],
                replacementNLBReferences: [
                    duplicate,
                    duplicate
                ]
            )
        )
    }

    private let merger =
        NLBOperatorStopReferenceMerger()

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
}
