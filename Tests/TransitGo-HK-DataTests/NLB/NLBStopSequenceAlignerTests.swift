//
//  NLBStopSequenceAlignerTests.swift
//  TransitGo-HK
//

import XCTest
@testable import TransitGo_HK_Data

final class NLBStopSequenceAlignerTests:
    XCTestCase {

    func testAlignsStopsAndAllowsExtraNLBStop() {

        let alignment = align(
            transitGoStops: [
                journeyStop("local-b", sequence: 2),
                journeyStop("local-a", sequence: 1)
            ],
            nlbStops: [
                nlbStop("nlb-a", latitude: "22.2600"),
                nlbStop("nlb-extra", latitude: "22.2605"),
                nlbStop("nlb-b", latitude: "22.2610")
            ],
            localStops: [
                stop("local-a", latitude: 22.2600),
                stop("local-b", latitude: 22.2610)
            ]
        )

        XCTAssertEqual(
            alignment.matchedPairs.map {
                $0.transitGoStop.stopId
            },
            ["local-a", "local-b"]
        )
        XCTAssertEqual(
            alignment.matchedPairs.map(\.nlbSequence),
            [1, 3]
        )
        XCTAssertEqual(
            alignment.nlbOnly.map(\.stop.stopId),
            ["nlb-extra"]
        )
        XCTAssertEqual(
            alignment.transitGoCoverage,
            1,
            accuracy: 0.001
        )
    }

    func testInvalidNLBCoordinatesAreNotMatched() {

        let alignment = align(
            transitGoStops: [
                journeyStop("local-a", sequence: 1)
            ],
            nlbStops: [
                nlbStop("invalid", latitude: "not-a-number")
            ],
            localStops: [
                stop("local-a", latitude: 22.2600)
            ]
        )

        XCTAssertTrue(alignment.matchedPairs.isEmpty)
        XCTAssertEqual(alignment.transitGoOnly.count, 1)
        XCTAssertEqual(alignment.nlbOnly.count, 1)
        XCTAssertEqual(alignment.transitGoCoverage, 0)
    }

    func testDistantStopsAreNotMatched() {

        let alignment = align(
            transitGoStops: [
                journeyStop("local-a", sequence: 1)
            ],
            nlbStops: [
                nlbStop("far-away", latitude: "22.2800")
            ],
            localStops: [
                stop("local-a", latitude: 22.2600)
            ]
        )

        XCTAssertTrue(alignment.matchedPairs.isEmpty)
        XCTAssertEqual(alignment.transitGoOnly.count, 1)
        XCTAssertEqual(alignment.nlbOnly.count, 1)
    }

    private func align(
        transitGoStops: [JourneyStop],
        nlbStops: [NLBRouteStopRecord],
        localStops: [Stop]
    ) -> NLBStopSequenceAlignment {

        NLBStopSequenceAligner().align(
            transitGoStops:
                transitGoStops,
            nlbStops:
                nlbStops,
            localStopLookup:
                Dictionary(
                    uniqueKeysWithValues:
                        localStops.map {
                            ($0.id, $0)
                        }
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
        latitude: Double
    ) -> Stop {

        Stop(
            id: id,
            nameEnglish: id,
            nameTraditional: id,
            nameSimplified: id,
            latitude: latitude,
            longitude: 114.0000
        )
    }

    private func nlbStop(
        _ id: String,
        latitude: String
    ) -> NLBRouteStopRecord {

        NLBRouteStopRecord(
            stopId: id,
            stopNameTraditional: id,
            stopNameSimplified: id,
            stopNameEnglish: id,
            stopLocationTraditional: id,
            stopLocationSimplified: id,
            stopLocationEnglish: id,
            latitude: latitude,
            longitude: "114.0000"
        )
    }
}
