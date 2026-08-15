//
//  CTBRouteAPITests.swift
//  TransitGo-HK
//
//  Created by Ken on 15/8/2026.
//

import XCTest
@testable import TransitGo_HK_Data

final class CTBRouteAPITests: XCTestCase {

    func testFetchAllCTBRoutes() async throws {

        let routes =
            try await CTBRouteAPI().fetchAll()

        print(
            "CTB routes:",
            routes.count
        )

        if let route1 =
            routes.first(where: {
                $0.route == "1"
            }) {

            print("*** CTB route 1 ***")
            print("Company:", route1.companyId)
            print("Route:", route1.route)
            print(
                "Origin:",
                route1.originEnglish
            )
            print(
                "Destination:",
                route1.destinationEnglish
            )
        }

        XCTAssertFalse(
            routes.isEmpty
        )
    }
}
