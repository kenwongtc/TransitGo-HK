//
//  MTRBusK51ReferenceMergerTests.swift
//  TransitGo-HK
//

import XCTest
@testable import TransitGo_HK_Data

final class MTRBusK51ReferenceMergerTests:
    XCTestCase {

    func testReplacesOnlyK51AndPreservesOrder()
        throws {

        let existing = [
            reference("KMB", "kmb", "1"),
            reference(
                "LRTFeeder",
                "1871-1",
                "K51"
            ),
            reference("NLB", "nlb", "2"),
            reference(
                "LRTFeeder",
                "other-journey",
                "K52"
            )
        ]

        let replacement = [
            reference(
                "LRTFeeder",
                "1871-2",
                "K51"
            )
        ]

        let merged = try merger.merge(
            existing: existing,
            replacementK51References: replacement
        )

        XCTAssertEqual(
            merged.map(\.journeyId),
            [
                "kmb",
                "nlb",
                "other-journey",
                "1871-2"
            ]
        )
    }

    func testRejectsNonK51Replacement() {

        XCTAssertThrowsError(
            try merger.merge(
                existing: [],
                replacementK51References: [
                    reference(
                        "LRTFeeder",
                        "other-journey",
                        "K52"
                    )
                ]
            )
        )
    }

    func testRejectsDuplicateKey() {

        let duplicate = reference(
            "LRTFeeder",
            "1871-1",
            "K51"
        )

        XCTAssertThrowsError(
            try merger.merge(
                existing: [],
                replacementK51References: [
                    duplicate,
                    duplicate
                ]
            )
        )
    }

    private let merger =
        MTRBusK51ReferenceMerger()

    private func reference(
        _ operatorId: String,
        _ journeyId: String,
        _ serviceType: String
    ) -> OperatorStopReference {

        OperatorStopReference(
            operatorId: operatorId,
            journeyId: journeyId,
            stopId: "stop",
            sequence: 1,
            operatorStopId: "operator-stop",
            operatorServiceType: serviceType,
            operatorDirection: "O"
        )
    }
}
