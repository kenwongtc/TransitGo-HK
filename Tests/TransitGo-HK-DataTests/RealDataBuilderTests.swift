//
//  RealDataBuilderTests.swift
//  TransitGo-HK
//
//  Created by Ken on 10/8/2026.
//

import XCTest
@testable import TransitGo_HK_Data

final class RealDataBuilderTests: XCTestCase {

    func testBuildsRealMasterData() async throws {
        let masterData = try await RealDataBuilder().build()
        
        XCTAssertEqual(masterData.operators.count, 14)
        XCTAssertEqual(masterData.routes.count, 1609)
        XCTAssertEqual(masterData.journeys.count, 2356)

        XCTAssertFalse(masterData.journeyStops.isEmpty)
        XCTAssertEqual(masterData.stops.count, 4480)
        XCTAssertTrue(masterData.schedules.isEmpty)
    }
}
