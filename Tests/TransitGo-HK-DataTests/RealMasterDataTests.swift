//
//  RealMasterDataTests.swift
//  TransitGo-HK
//
//  Created by Ken on 10/8/2026.
//

import XCTest
@testable import TransitGo_HK_Data

final class RealMasterDataTests: XCTestCase {

    func testRealMasterDataIsConsistent() throws {
        let operators = try RealOperatorBuilder().build()
        let routes = try RealRouteBuilder().build()
        let journeys = try RealJourneyBuilder().build()
        let journeyStops = try RealJourneyStopBuilder().build()
        let stops = try RealStopBuilder().build()

        XCTAssertFalse(operators.isEmpty)
        XCTAssertFalse(routes.isEmpty)
        XCTAssertFalse(journeys.isEmpty)
        XCTAssertFalse(journeyStops.isEmpty)
        XCTAssertFalse(stops.isEmpty)

        let masterData = MasterData(
            operators: operators,
            routes: routes,
            journeys: journeys,
            journeyStops: journeyStops,
            stops: stops,
            schedules: []
        )

        let validator = MasterDataValidator()

        XCTAssertNoThrow(
            try validator.validate(masterData)
        )
    }
}
