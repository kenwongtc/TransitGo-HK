//
//  RealJourneyStopBuilderTests.swift
//  TransitGo-HK
//
//  Created by Ken on 10/8/2026.
//

import XCTest
@testable import TransitGo_HK_Data

final class RealJourneyStopBuilderTests: XCTestCase {

    func testBuildsRealJourneyStops() throws {
        let journeyStops = try RealJourneyStopBuilder().build()

        XCTAssertFalse(journeyStops.isEmpty)

        let journeyIDs = Set(
            journeyStops.map { $0.journeyId }
        )

        XCTAssertEqual(
            journeyIDs.count,
            2356
        )

        for journeyStop in journeyStops {
            XCTAssertFalse(journeyStop.journeyId.isEmpty)
            XCTAssertFalse(journeyStop.stopId.isEmpty)

            XCTAssertGreaterThan(
                journeyStop.sequence,
                0
            )
        }
    }
}
