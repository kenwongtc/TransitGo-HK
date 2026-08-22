//
//  MTRBusStopSequenceAlignerTests.swift
//  TransitGo-HK
//

import XCTest
@testable import TransitGo_HK_Data

final class MTRBusStopSequenceAlignerTests:
    XCTestCase {

    func testAlignsK51StyleStopsAndAllowsExtraStop() {

        let alignment = align(
            transitGoStops: [
                journeyStop("local-b", sequence: 2),
                journeyStop("local-a", sequence: 1)
            ],
            mtrBusStops: [
                mtrBusStop(
                    "K51-D010",
                    sequence: 1,
                    latitude: 22.4100
                ),
                mtrBusStop(
                    "K51-D020",
                    sequence: 2,
                    latitude: 22.4105
                ),
                mtrBusStop(
                    "K51-D030",
                    sequence: 3,
                    latitude: 22.4110
                )
            ],
            localStops: [
                stop(
                    "local-a",
                    name: "Fu Tai Estate Bus Terminus",
                    latitude: 22.4100
                ),
                stop(
                    "local-b",
                    name: "Tai Lam",
                    latitude: 22.4110
                )
            ]
        )

        XCTAssertEqual(
            alignment.matchedPairs.map {
                $0.mtrBusStop.stopId
            },
            ["K51-D010", "K51-D030"]
        )
        XCTAssertEqual(
            alignment.mtrBusOnly.map(\.stopId),
            ["K51-D020"]
        )
        XCTAssertEqual(
            alignment.transitGoCoverage,
            1,
            accuracy: 0.001
        )
        XCTAssertEqual(
            alignment.averageDistanceMeters ?? -1,
            0,
            accuracy: 0.01
        )
    }

    func testDistantStopsAreNotMatched() {

        let alignment = align(
            transitGoStops: [
                journeyStop("local", sequence: 1)
            ],
            mtrBusStops: [
                mtrBusStop(
                    "K51-D010",
                    sequence: 1,
                    latitude: 22.4300
                )
            ],
            localStops: [
                stop(
                    "local",
                    name: "Fu Tai",
                    latitude: 22.4100
                )
            ]
        )

        XCTAssertTrue(alignment.matchedPairs.isEmpty)
        XCTAssertEqual(alignment.transitGoOnly.count, 1)
        XCTAssertEqual(alignment.mtrBusOnly.count, 1)
        XCTAssertNil(alignment.averageDistanceMeters)
    }

    func testNearbyDifferentNamesDoNotShiftSequence() {

        let alignment = align(
            transitGoStops: [
                journeyStop("local-a", sequence: 1),
                journeyStop("local-b", sequence: 2)
            ],
            mtrBusStops: [
                mtrBusStop(
                    "K51-D010",
                    sequence: 1,
                    latitude: 22.4101,
                    name: "Tak Ching Court"
                ),
                mtrBusStop(
                    "K51-D020",
                    sequence: 2,
                    latitude: 22.4102,
                    name: "Tuen Mun Central"
                )
            ],
            localStops: [
                stop(
                    "local-a",
                    name: "Tuen Mun Central Bus Terminus",
                    latitude: 22.4101
                ),
                stop(
                    "local-b",
                    name: "Tak Ching Court",
                    latitude: 22.4102
                )
            ]
        )

        XCTAssertEqual(
            alignment.matchedPairs.map {
                $0.transitGoStop.stopId
            },
            ["local-a"]
        )
        XCTAssertEqual(
            alignment.matchedPairs.map {
                $0.mtrBusStop.stopId
            },
            ["K51-D020"]
        )
    }

    private func align(
        transitGoStops: [JourneyStop],
        mtrBusStops: [MTRBusStopRecord],
        localStops: [Stop]
    ) -> MTRBusStopSequenceAlignment {

        MTRBusStopSequenceAligner().align(
            transitGoStops: transitGoStops,
            mtrBusStops: mtrBusStops,
            localStopLookup: Dictionary(
                uniqueKeysWithValues:
                    localStops.map { ($0.id, $0) }
            )
        )
    }

    private func journeyStop(
        _ stopId: String,
        sequence: Int
    ) -> JourneyStop {

        JourneyStop(
            journeyId: "journey",
            stopId: stopId,
            sequence: sequence
        )
    }

    private func stop(
        _ id: String,
        name: String,
        latitude: Double
    ) -> Stop {

        Stop(
            id: id,
            nameEnglish: name,
            nameTraditional: id,
            nameSimplified: id,
            latitude: latitude,
            longitude: 114.0000
        )
    }

    private func mtrBusStop(
        _ id: String,
        sequence: Int,
        latitude: Double,
        name: String? = nil
    ) -> MTRBusStopRecord {

        MTRBusStopRecord(
            routeId: "K51",
            direction: "O",
            sequence: sequence,
            stopId: id,
            latitude: latitude,
            longitude: 114.0000,
            nameTraditional: id,
            nameEnglish:
                name ?? defaultName(for: id),
            referenceId: "K51"
        )
    }

    private func defaultName(
        for id: String
    ) -> String {

        switch id {
        case "K51-D010":
            return "Fu Tai"
        case "K51-D020":
            return "Extra Stop"
        default:
            return "Tai Lam"
        }
    }
}
