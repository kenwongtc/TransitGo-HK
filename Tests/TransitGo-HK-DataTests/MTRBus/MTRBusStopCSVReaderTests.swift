//
//  MTRBusStopCSVReaderTests.swift
//  TransitGo-HK
//

import Foundation
import XCTest
@testable import TransitGo_HK_Data

final class MTRBusStopCSVReaderTests:
    XCTestCase {

    func testDecodesOfficialColumnsAndByteOrderMark()
        throws {

        let csv = """
        \u{FEFF}ROUTE_ID,DIRECTION,STATION_SEQNO,STATION_ID,STATION_LATITUDE,STATION_LONGITUDE,STATION_NAME_CHI,STATION_NAME_ENG,REFERENCE_ID
        K51,O,1,K51-D010,22.413,113.983,富泰,"Fu Tai, Estate",K51
        K51,O,2,K51-D020,22.414,113.984,兆康站,Siu Hong Station,K51
        """

        let records = try reader.decode(
            Data(csv.utf8)
        )

        XCTAssertEqual(records.count, 2)
        XCTAssertEqual(
            records[0],
            MTRBusStopRecord(
                routeId: "K51",
                direction: "O",
                sequence: 1,
                stopId: "K51-D010",
                latitude: 22.413,
                longitude: 113.983,
                nameTraditional: "富泰",
                nameEnglish: "Fu Tai, Estate",
                referenceId: "K51"
            )
        )
    }

    func testRejectsInvalidNumericValue() {

        let csv = """
        ROUTE_ID,DIRECTION,STATION_SEQNO,STATION_ID,STATION_LATITUDE,STATION_LONGITUDE,STATION_NAME_CHI,STATION_NAME_ENG,REFERENCE_ID
        K51,O,invalid,K51-D010,22.413,113.983,富泰,Fu Tai,K51
        """

        XCTAssertThrowsError(
            try reader.decode(Data(csv.utf8))
        )
    }

    private let reader =
        MTRBusStopCSVReader()
}
