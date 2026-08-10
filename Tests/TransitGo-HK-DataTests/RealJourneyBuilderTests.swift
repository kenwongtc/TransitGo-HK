//
//  RealJourneyBuilderTests.swift
//  TransitGo-HK
//
//  Created by Ken on 9/8/2026.
//

import XCTest
@testable import TransitGo_HK_Data

final class RealJourneyBuilderTests: XCTestCase {

    func testBuildsRealJourneys() throws {
        let journeys = try RealJourneyBuilder().build()

        XCTAssertEqual(journeys.count, 2356)

        let journeyIDs = Set(
            journeys.map { $0.id }
        )

        XCTAssertEqual(
            journeyIDs.count,
            2356
        )

        for journey in journeys.prefix(10) {
            print(
                "Journey:",
                journey.id,
                "route:",
                journey.routeId,
                "origin:",
                journey.originStopId,
                "destination:",
                journey.destinationStopId,
                "direction:",
                journey.direction,
                "serviceType:",
                journey.serviceType
            )
        }
    }
}
