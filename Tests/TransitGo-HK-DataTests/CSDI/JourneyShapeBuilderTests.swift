//
//  JourneyShapeBuilderTests.swift
//  TransitGo-HK
//

import XCTest
@testable import TransitGo_HK_Data

final class JourneyShapeBuilderTests: XCTestCase {

    func testBuildsMatchingJourneyAndJoinsSegments() {

        let shared = coordinate(22.21, 114.11)
        let officialShape = CSDIBusRouteShape(
            routeId: "1001",
            routeSequence: 1,
            companyCode: "KMB",
            routeName: "1",
            segments: [
                [coordinate(22.20, 114.10), shared],
                [shared, coordinate(22.22, 114.12)]
            ]
        )

        let result = builder.build(
            journeys: [journey],
            officialShapes: [officialShape]
        )

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].journeyId, "1001-1")
        XCTAssertEqual(result[0].coordinates.count, 3)
        XCTAssertEqual(result[0].coordinates[1], shared)
    }

    func testSkipsDifferentDirection() {

        let officialShape = CSDIBusRouteShape(
            routeId: "1001",
            routeSequence: 2,
            companyCode: "KMB",
            routeName: "1",
            segments: [[
                coordinate(22.20, 114.10),
                coordinate(22.21, 114.11)
            ]]
        )

        XCTAssertTrue(
            builder.build(
                journeys: [journey],
                officialShapes: [officialShape]
            ).isEmpty
        )
    }

    func testReaderBuildsPagedRequestURL() throws {

        let url = try CSDIBusRouteShapeReader()
            .requestURL(
                resultOffset: 1_000,
                resultRecordCount: 500
            )
        let components = try XCTUnwrap(
            URLComponents(
                url: url,
                resolvingAgainstBaseURL: false
            )
        )
        let items = Dictionary(
            uniqueKeysWithValues:
                components.queryItems?.map {
                    ($0.name, $0.value ?? "")
                } ?? []
        )

        XCTAssertEqual(items["resultOffset"], "1000")
        XCTAssertEqual(
            items["resultRecordCount"],
            "500"
        )
        XCTAssertEqual(items["outSR"], "4326")
        XCTAssertEqual(items["f"], "geojson")
        XCTAssertEqual(
            items["maxAllowableOffset"],
            "0.00003"
        )
        XCTAssertEqual(items["geometryPrecision"], "5")

        let countURL = try CSDIBusRouteShapeReader()
            .countURL()
        let countItems = Dictionary(
            uniqueKeysWithValues:
                URLComponents(
                    url: countURL,
                    resolvingAgainstBaseURL: false
                )?.queryItems?.map {
                    ($0.name, $0.value ?? "")
                } ?? []
        )

        XCTAssertEqual(
            countItems["returnCountOnly"],
            "true"
        )
    }

    func testCoordinateUsesCompactArrayEncoding()
        throws {

        let source = coordinate(22.20, 114.10)
        let data = try JSONEncoder().encode(source)

        XCTAssertEqual(
            String(decoding: data, as: UTF8.self),
            "[22.2,114.1]"
        )
        XCTAssertEqual(
            try JSONDecoder().decode(
                JourneyShapeCoordinate.self,
                from: data
            ),
            source
        )
    }

    private let builder = JourneyShapeBuilder()

    private let journey = Journey(
        id: "1001-1",
        routeId: "1001",
        originStopId: "first",
        destinationStopId: "last",
        direction: "1",
        serviceType: "R"
    )

    private func coordinate(
        _ latitude: Double,
        _ longitude: Double
    ) -> JourneyShapeCoordinate {

        JourneyShapeCoordinate(
            latitude: latitude,
            longitude: longitude
        )
    }
}
