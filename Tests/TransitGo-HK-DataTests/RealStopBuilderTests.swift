//
//  RealStopBuilderTests.swift
//  TransitGo-HK
//
//  Created by Ken on 9/8/2026.
//

import XCTest
@testable import TransitGo_HK_Data

final class RealStopBuilderTests: XCTestCase {

    func testBuildsAllRealStops() throws {
        let stops = try RealStopBuilder().build()

        XCTAssertEqual(stops.count, 4480)

        let stopIDs = Set(stops.map { $0.id })

        XCTAssertEqual(
            stopIDs.count,
            4480
        )

        for stop in stops {
            XCTAssertFalse(stop.id.isEmpty)
            XCTAssertFalse(stop.nameEnglish.isEmpty)
            XCTAssertFalse(stop.nameTraditional.isEmpty)
            XCTAssertFalse(stop.nameSimplified.isEmpty)

            XCTAssertGreaterThan(
                stop.latitude,
                22.0
            )

            XCTAssertLessThan(
                stop.latitude,
                23.0
            )

            XCTAssertGreaterThan(
                stop.longitude,
                113.0
            )

            XCTAssertLessThan(
                stop.longitude,
                115.0
            )
        }
    }
}
