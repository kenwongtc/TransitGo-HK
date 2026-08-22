//
//  MTRBusReferenceMergerTests.swift
//  TransitGo-HK
//

import XCTest
@testable import TransitGo_HK_Data

final class MTRBusReferenceMergerTests: XCTestCase {

    func testReplacesEntireMTRBusNetwork() throws {

        let existing = [
            reference("KMB", "kmb", "1"),
            reference(
                "LRTFeeder", "old-k51", "K51"
            ),
            reference(
                "LRTFeeder", "old-k52", "K52"
            ),
            reference("NLB", "nlb", "2")
        ]
        let replacements = [
            reference(
                "LRTFeeder", "new-k51", "K51"
            ),
            reference(
                "LRTFeeder", "new-k52", "K52"
            )
        ]

        let merged = try merger.merge(
            existing: existing,
            replacementReferences: replacements
        )

        XCTAssertEqual(
            merged.map(\.journeyId),
            ["kmb", "nlb", "new-k51", "new-k52"]
        )
    }

    func testRejectsAnotherOperator() {

        XCTAssertThrowsError(
            try merger.merge(
                existing: [],
                replacementReferences: [
                    reference("KMB", "journey", "1")
                ]
            )
        )
    }

    func testRejectsDuplicateKey() {

        let duplicate = reference(
            "LRTFeeder", "journey", "K51"
        )

        XCTAssertThrowsError(
            try merger.merge(
                existing: [],
                replacementReferences: [
                    duplicate,
                    duplicate
                ]
            )
        )
    }

    private let merger = MTRBusReferenceMerger()

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
