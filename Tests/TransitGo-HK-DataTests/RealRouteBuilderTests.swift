//
//  RealRouteBuilderTests.swift
//  TransitGo-HK
//
//  Created by Ken on 9/8/2026.
//

import XCTest
@testable import TransitGo_HK_Data

final class RealRouteBuilderTests: XCTestCase {

    func testBuildsRealMasterData() async throws {
        let routes = try RealRouteBuilder().build()

        XCTAssertEqual(routes.count, 1609)

        let routeIDs = Set(
            routes.map { $0.id }
        )

        XCTAssertEqual(
            routeIDs.count,
            1609
        )

        for route in routes {
            XCTAssertFalse(route.id.isEmpty)
            XCTAssertFalse(route.number.isEmpty)
            XCTAssertFalse(route.operatorIds.isEmpty)
        }
    }
}
