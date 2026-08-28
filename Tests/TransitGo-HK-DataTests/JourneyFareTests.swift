import XCTest
@testable import TransitGo_HK_Data

final class JourneyFareTests: XCTestCase {
    func testBuildsSupportedOperatorAdultFullFaresInCents() throws {
        let journeys = try RealJourneyBuilder().build()
        let routeOneOutbound = try XCTUnwrap(
            journeys.first { $0.id == "1001-1" }
        )

        XCTAssertEqual(
            routeOneOutbound.adultFullFareCents,
            670
        )

        XCTAssertEqual(
            journeys.first { $0.id == "1450-1" }?
                .adultFullFareCents,
            380
        )

        XCTAssertEqual(
            journeys.first { $0.id == "1475-1" }?
                .adultFullFareCents,
            4_760
        )

        XCTAssertEqual(
            journeys.first { $0.id == "1006-1" }?
                .adultFullFareCents,
            1_290
        )
    }

    func testBuildsScheduledJourneyTime() throws {
        let journeys = try RealJourneyBuilder().build()

        XCTAssertEqual(
            journeys.first { $0.id == "1001-1" }?
                .scheduledDurationMinutes,
            44
        )

        XCTAssertEqual(
            journeys.first { $0.id == "1006-1" }?
                .scheduledDurationMinutes,
            64
        )
    }

    func testBuildsKMBAndLWBSectionFareTiers() throws {
        let journeys = try RealJourneyBuilder().build()

        XCTAssertEqual(
            journeys.first { $0.id == "1001-1" }?
                .sectionFareTiers,
            [
                SectionFareTier(
                    boardingStopSequence: 17,
                    fareCents: 580
                )
            ]
        )

        XCTAssertNil(
            journeys.first { $0.id == "1475-1" }?
                .sectionFareTiers
        )
    }

    func testBuildsCitybusSectionFareTiers() throws {
        let journeys = try RealJourneyBuilder().build()

        XCTAssertEqual(
            journeys.first { $0.id == "1495-1" }?
                .sectionFareTiers,
            [
                SectionFareTier(
                    boardingStopSequence: 8,
                    fareCents: 530
                )
            ]
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
        XCTAssertNil(journey.scheduledDurationMinutes)
        XCTAssertNil(journey.sectionFareTiers)
    }
}
