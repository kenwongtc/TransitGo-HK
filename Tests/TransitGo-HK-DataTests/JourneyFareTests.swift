import XCTest
@testable import TransitGo_HK_Data

final class JourneyFareTests: XCTestCase {
    func testBuildsKMBAdultFullFareInCents() throws {
        let journeys = try RealJourneyBuilder().build()
        let routeOneOutbound = try XCTUnwrap(
            journeys.first { $0.id == "1001-1" }
        )

        XCTAssertEqual(
            routeOneOutbound.adultFullFareCents,
            670
        )
    }

    func testDecodesLegacyJourneyWithoutFare() throws {
        let data = Data(
            """
            {
              "id":"1001-1",
              "routeId":"1001",
              "originStopId":"4001",
              "destinationStopId":"10133",
              "direction":"1",
              "serviceType":"R"
            }
            """.utf8
        )

        let journey = try JSONDecoder().decode(
            Journey.self,
            from: data
        )

        XCTAssertNil(journey.adultFullFareCents)
    }
}
