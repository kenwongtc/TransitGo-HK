//
//  HKGridConverterTests.swift
//  TransitGo-HK
//
//  Created by Ken on 9/8/2026.
//

import XCTest
@testable import TransitGo_HK_Data

final class HKGridConverterTests: XCTestCase {

    func testConversionProducesHongKongCoordinates() {
        let converter = HKGridConverter()

        let coordinate = converter.convert(
            easting: 836694.05,
            northing: 819069.80
        )

        XCTAssertEqual(
            coordinate.latitude,
            22.3121333333,
            accuracy: 0.000001
        )

        XCTAssertEqual(
            coordinate.longitude,
            114.1785555556,
            accuracy: 0.000001
        )
    }
}
