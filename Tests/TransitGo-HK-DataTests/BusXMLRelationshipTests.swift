//
//  BusXMLRelationshipTests.swift
//  TransitGo-HK
//
//  Created by Ken on 9/8/2026.
//

import XCTest
@testable import TransitGo_HK_Data

final class BusXMLRelationshipTests: XCTestCase {

    func testRStopReferencesExistingStops() throws {
        let stopURL = try XCTUnwrap(
            Bundle.module.url(
                forResource: "STOP_BUS",
                withExtension: "xml"
            )
        )

        let rStopURL = try XCTUnwrap(
            Bundle.module.url(
                forResource: "RSTOP_BUS",
                withExtension: "xml"
            )
        )

        let stops = try StopBusXMLReader().read(from: stopURL)
        let rStops = try RStopBusXMLReader().read(from: rStopURL)

        let stopIDs = Set(stops.map { $0.stopID })

        let missingStopIDs = Set(
            rStops
                .map { $0.stopID }
                .filter { !stopIDs.contains($0) }
        )

        XCTAssertTrue(
            missingStopIDs.isEmpty,
            "RSTOP_BUS contains unknown STOP_IDs: \(missingStopIDs.prefix(10))"
        )
    }

    func testRouteStopSequenceContainsUniqueStops() throws {
        let rStopURL = try XCTUnwrap(
            Bundle.module.url(
                forResource: "RSTOP_BUS",
                withExtension: "xml"
            )
        )

        let records = try RStopBusXMLReader().read(from: rStopURL)

        let routeKeys = Set(
            records.map {
                "\($0.routeID)|\($0.routeSequence)"
            }
        )

        for routeKey in routeKeys {
            let stops = records.filter {
                "\($0.routeID)|\($0.routeSequence)" == routeKey
            }

            let sequences = stops.map {
                $0.stopSequence
            }

            XCTAssertEqual(
                sequences.count,
                Set(sequences).count,
                "Duplicate STOP_SEQ found for \(routeKey)"
            )
        }
    }
}
