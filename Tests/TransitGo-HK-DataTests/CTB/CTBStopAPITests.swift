//
//  BusXMLRelationshipTests.swift
//  TransitGo-HK
//
//  Created by Ken on 9/8/2026.
//

import XCTest
@testable import TransitGo_HK_Data

final class CTBStopAPITests: XCTestCase {

    func testFetchCTBSttestBuildRoute1OutboundReferencesop() async throws {

        let stop =
            try await CTBStopAPI().fetch(
                stopId: "002737"
            )

        print("*** CTB stop ***")
        print("Stop:", stop.stop)
        print("English:", stop.nameEnglish)
        print(
            "Traditional:",
            stop.nameTraditional
        )
        print("Latitude:", stop.latitude)
        print("Longitude:", stop.longitude)

        XCTAssertEqual(
            stop.stop,
            "002737"
        )
    }
}
