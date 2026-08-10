//
//  BusXMLReaderTests.swift
//  TransitGo-HK
//
//  Created by Ken on 8/8/2026.
//

import XCTest
@testable import TransitGo_HK_Data

final class BusXMLReaderTests: XCTestCase {

    func testStopBusXMLReaderReadsRealData() throws {
        let url = try XCTUnwrap(
            Bundle.module.url(
                forResource: "STOP_BUS",
                withExtension: "xml"
            )
        )

        let records = try StopBusXMLReader().read(from: url)

        XCTAssertEqual(records.count, 4480)

        let first = try XCTUnwrap(records.first)

        XCTAssertFalse(first.stopID.isEmpty)
        XCTAssertFalse(first.stopType.isEmpty)
        XCTAssertGreaterThan(first.x, 0)
        XCTAssertGreaterThan(first.y, 0)
    }

    func testRStopBusXMLReaderReadsRealData() throws {
        let url = try XCTUnwrap(
            Bundle.module.url(
                forResource: "RSTOP_BUS",
                withExtension: "xml"
            )
        )

        let records = try RStopBusXMLReader().read(from: url)

        XCTAssertEqual(records.count, 56042)

        let first = try XCTUnwrap(records.first)

        XCTAssertFalse(first.routeID.isEmpty)
        XCTAssertGreaterThan(first.routeSequence, 0)
        XCTAssertGreaterThan(first.stopSequence, 0)
        XCTAssertFalse(first.stopID.isEmpty)
        XCTAssertFalse(first.nameEnglish.isEmpty)
    }
}
