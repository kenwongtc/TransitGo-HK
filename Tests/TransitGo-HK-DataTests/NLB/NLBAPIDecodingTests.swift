//
//  NLBAPIDecodingTests.swift
//  TransitGo-HK
//

import XCTest
@testable import TransitGo_HK_Data

final class NLBAPIDecodingTests: XCTestCase {

    func testDecodeRoutes() throws {

        let data = Data(
            """
            {
              "routes": [
                {
                  "routeId": "1",
                  "routeNo": "1",
                  "routeName_c": "梅窩碼頭 > 大澳",
                  "routeName_s": "梅窝码头 > 大澳",
                  "routeName_e": "Mui Wo Ferry Pier > Tai O",
                  "overnightRoute": 0,
                  "specialRoute": 0
                }
              ]
            }
            """.utf8
        )

        let routes =
            try NLBRouteAPI().decode(data)

        XCTAssertEqual(routes.count, 1)
        XCTAssertEqual(routes[0].routeId, "1")
        XCTAssertEqual(routes[0].routeNumber, "1")
        XCTAssertEqual(
            routes[0].routeNameEnglish,
            "Mui Wo Ferry Pier > Tai O"
        )
        XCTAssertEqual(routes[0].isOvernightRoute, 0)
        XCTAssertEqual(routes[0].isSpecialRoute, 0)
    }

    func testDecodeRouteStopsPreservesOrder()
        throws {

        let data = Data(
            """
            {
              "stops": [
                {
                  "stopId": "1",
                  "stopName_c": "梅窩碼頭",
                  "stopName_s": "梅窝码头",
                  "stopName_e": "Mui Wo Ferry Pier",
                  "stopLocation_c": "梅窩碼頭",
                  "stopLocation_s": "梅窝码头",
                  "stopLocation_e": "Mui Wo Ferry Pier",
                  "latitude": "22.26466400",
                  "longitude": "114.00155400",
                  "fare": "12.7",
                  "fareHoliday": "21.4",
                  "someDepartureObserveOnly": 0
                },
                {
                  "stopId": "55",
                  "stopName_c": "大澳",
                  "stopName_s": "大澳",
                  "stopName_e": "Tai O",
                  "stopLocation_c": "大澳道",
                  "stopLocation_s": "大澳道",
                  "stopLocation_e": "Tai O Road",
                  "latitude": "22.25278300",
                  "longitude": "113.86216000",
                  "fare": "0.0",
                  "fareHoliday": "0.0",
                  "someDepartureObserveOnly": 0
                }
              ]
            }
            """.utf8
        )

        let stops =
            try NLBRouteStopAPI().decode(data)

        XCTAssertEqual(
            stops.map(\.stopId),
            ["1", "55"]
        )
        XCTAssertEqual(
            stops[0].stopNameEnglish,
            "Mui Wo Ferry Pier"
        )
        XCTAssertEqual(
            stops[0].latitude,
            "22.26466400"
        )
        XCTAssertEqual(
            stops[0].longitude,
            "114.00155400"
        )
    }
}
