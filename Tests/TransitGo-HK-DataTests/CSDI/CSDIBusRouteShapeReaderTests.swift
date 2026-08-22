//
//  CSDIBusRouteShapeReaderTests.swift
//  TransitGo-HK
//

import Foundation
import XCTest
@testable import TransitGo_HK_Data

final class CSDIBusRouteShapeReaderTests:
    XCTestCase {

    func testDecodesMultiLineString() throws {

        let data = Data(
            """
            {
              "type": "FeatureCollection",
              "features": [{
                "type": "Feature",
                "geometry": {
                  "type": "MultiLineString",
                  "coordinates": [
                    [[114.10, 22.20], [114.11, 22.21]],
                    [[114.11, 22.21], [114.12, 22.22]]
                  ]
                },
                "properties": {
                  "ROUTE_ID": 1001,
                  "ROUTE_SEQ": 1,
                  "COMPANY_CODE": "KMB",
                  "ROUTE_NAMEE": "1"
                }
              }]
            }
            """.utf8
        )

        let result = try reader.decode(data)

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].routeId, "1001")
        XCTAssertEqual(result[0].routeSequence, 1)
        XCTAssertEqual(result[0].companyCode, "KMB")
        XCTAssertEqual(result[0].segments.count, 2)
        XCTAssertEqual(
            result[0].segments[0][0],
            JourneyShapeCoordinate(
                latitude: 22.20,
                longitude: 114.10
            )
        )
    }

    func testDecodesLineString() throws {

        let data = Data(
            """
            {
              "type": "FeatureCollection",
              "features": [{
                "type": "Feature",
                "geometry": {
                  "type": "LineString",
                  "coordinates": [
                    [114.10, 22.20], [114.11, 22.21]
                  ]
                },
                "properties": {
                  "ROUTE_ID": 1001,
                  "ROUTE_SEQ": 2,
                  "COMPANY_CODE": "KMB",
                  "ROUTE_NAMEE": "1"
                }
              }]
            }
            """.utf8
        )

        let result = try reader.decode(data)

        XCTAssertEqual(result[0].segments.count, 1)
        XCTAssertEqual(result[0].segments[0].count, 2)
    }

    func testRejectsPointGeometry() {

        let data = Data(
            """
            {
              "type": "FeatureCollection",
              "features": [{
                "geometry": {
                  "type": "Point",
                  "coordinates": [114.10, 22.20]
                },
                "properties": {
                  "ROUTE_ID": 1001,
                  "ROUTE_SEQ": 1,
                  "COMPANY_CODE": "KMB",
                  "ROUTE_NAMEE": "1"
                }
              }]
            }
            """.utf8
        )

        XCTAssertThrowsError(
            try reader.decode(data)
        )
    }

    private let reader = CSDIBusRouteShapeReader()
}
