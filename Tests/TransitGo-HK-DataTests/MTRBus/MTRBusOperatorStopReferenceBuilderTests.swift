//
//  MTRBusOperatorStopReferenceBuilderTests.swift
//  TransitGo-HK
//

import XCTest
@testable import TransitGo_HK_Data

final class MTRBusOperatorStopReferenceBuilderTests:
    XCTestCase {

    func testBuildsK51ReferencesWithOfficialDirection() {

        let results = builder.buildK51(
            routes: [route],
            journeys: [journey],
            journeyStops: [
                JourneyStop(
                    journeyId: journey.id,
                    stopId: "local-a",
                    sequence: 1
                ),
                JourneyStop(
                    journeyId: journey.id,
                    stopId: "local-b",
                    sequence: 2
                )
            ],
            stops: [
                stop("local-a", "Fu Tai", 22.4100),
                stop("local-b", "Tai Lam", 22.4110)
            ],
            officialStops: [
                officialStop(
                    "K51-D010",
                    "O",
                    1,
                    "Fu Tai",
                    22.4100
                ),
                officialStop(
                    "K51-D020",
                    "O",
                    2,
                    "Tai Lam",
                    22.4110
                ),
                officialStop(
                    "K51-U010",
                    "I",
                    1,
                    "Somewhere Else",
                    22.4100
                )
            ]
        )

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].direction, "O")
        XCTAssertEqual(results[0].coverage, 1)
        XCTAssertEqual(
            results[0].references.map(\.operatorStopId),
            ["K51-D010", "K51-D020"]
        )
        XCTAssertTrue(
            results[0].references.allSatisfy {
                $0.operatorId == "LRTFeeder" &&
                $0.operatorServiceType == "K51" &&
                $0.operatorDirection == "O"
            }
        )
    }

    func testRejectsWeakK51Alignment() {

        let results = builder.buildK51(
            routes: [route],
            journeys: [journey],
            journeyStops: [
                JourneyStop(
                    journeyId: journey.id,
                    stopId: "local-a",
                    sequence: 1
                ),
                JourneyStop(
                    journeyId: journey.id,
                    stopId: "local-b",
                    sequence: 2
                )
            ],
            stops: [
                stop("local-a", "Fu Tai", 22.4100),
                stop("local-b", "Tai Lam", 22.4110)
            ],
            officialStops: [
                officialStop(
                    "K51-D010",
                    "O",
                    1,
                    "Fu Tai",
                    22.4100
                )
            ]
        )

        XCTAssertTrue(results.isEmpty)
    }

    private let builder =
        MTRBusOperatorStopReferenceBuilder()

    private let route = Route(
        id: "route",
        number: "K51",
        operatorIds: ["LRTFeeder"],
        originEnglish: "Fu Tai",
        originTraditional: "富泰",
        originSimplified: "富泰",
        destinationEnglish: "Tai Lam",
        destinationTraditional: "大欖",
        destinationSimplified: "大榄"
    )

    private let journey = Journey(
        id: "route-1",
        routeId: "route",
        originStopId: "local-a",
        destinationStopId: "local-b",
        direction: "1",
        serviceType: "R"
    )

    private func stop(
        _ id: String,
        _ name: String,
        _ latitude: Double
    ) -> Stop {

        Stop(
            id: id,
            nameEnglish: name,
            nameTraditional: name,
            nameSimplified: name,
            latitude: latitude,
            longitude: 114.0000
        )
    }

    private func officialStop(
        _ id: String,
        _ direction: String,
        _ sequence: Int,
        _ name: String,
        _ latitude: Double
    ) -> MTRBusStopRecord {

        MTRBusStopRecord(
            routeId: "K51",
            direction: direction,
            sequence: sequence,
            stopId: id,
            latitude: latitude,
            longitude: 114.0000,
            nameTraditional: name,
            nameEnglish: name,
            referenceId: "K51"
        )
    }
}
