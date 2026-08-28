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

    func testBuildsJointOperatorSectionFareTiers() throws {
        let journeys = try RealJourneyBuilder().build()

        XCTAssertEqual(
            journeys.first { $0.id == "1006-1" }?
                .sectionFareTiers,
            [
                SectionFareTier(
                    boardingStopSequence: 13,
                    fareCents: 1_220
                ),
                SectionFareTier(
                    boardingStopSequence: 15,
                    fareCents: 770
                ),
                SectionFareTier(
                    boardingStopSequence: 24,
                    fareCents: 680
                )
            ]
        )

        XCTAssertEqual(
            journeys.first { $0.id == "8769-1" }?
                .sectionFareTiers,
            [
                SectionFareTier(
                    boardingStopSequence: 5,
                    fareCents: 320
                )
            ]
        )
    }

    func testDropsSectionFareTiersWithoutMatchingStops() throws {
        let journeys = try RealJourneyBuilder().build()

        XCTAssertEqual(
            journeys.first { $0.id == "1000454-2" }?
                .sectionFareTiers,
            [
                SectionFareTier(
                    boardingStopSequence: 26,
                    fareCents: 1_460
                ),
                SectionFareTier(
                    boardingStopSequence: 27,
                    fareCents: 910
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
