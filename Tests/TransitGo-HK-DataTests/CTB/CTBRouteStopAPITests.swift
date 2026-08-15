//
//  CTBRouteStopAPITests.swift
//  TransitGo-HK
//
//  Created by Ken on 15/8/2026.
//

import XCTest
@testable import TransitGo_HK_Data

final class CTBRouteStopAPITests: XCTestCase {

    func testFetchCTBRouteStops() async throws {

        let records =
            try await CTBRouteStopAPI().fetch(
                route: "1",
                direction: "inbound"
            )

        print(
            "CTB route 1 inbound stops:",
            records.count
        )

        for record in records.prefix(5) {

            print(
                "seq:",
                record.sequence,
                "| stop:",
                record.stop
            )
        }

        XCTAssertFalse(
            records.isEmpty
        )
    }
}
