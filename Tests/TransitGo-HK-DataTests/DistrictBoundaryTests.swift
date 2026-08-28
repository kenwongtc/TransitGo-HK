import XCTest
@testable import TransitGo_HK_Data

final class DistrictBoundaryTests: XCTestCase {
    func testPointInsidePolygonReceivesDistrictAndRegion() {
        let boundary = DistrictBoundary(
            id: "E",
            nameEnglish: "Yau Tsim Mong",
            nameTraditional: "油尖旺",
            polygons: [[[
                [114.0, 22.0],
                [115.0, 22.0],
                [115.0, 23.0],
                [114.0, 23.0],
                [114.0, 22.0]
            ]]]
        )

        let stop = Stop(
            id: "stop",
            nameEnglish: "Test Stop",
            nameTraditional: "測試站",
            nameSimplified: "测试站",
            latitude: 22.5,
            longitude: 114.5
        )

        let result = StopGeographyEnricher(
            boundaries: [boundary]
        ).enrich([stop])

        XCTAssertEqual(result.first?.districtId, "E")
        XCTAssertEqual(result.first?.regionId, "kln")
    }

    func testPointOutsidePolygonRemainsUnclassified() {
        let boundary = DistrictBoundary(
            id: "A",
            nameEnglish: "Central & Western",
            nameTraditional: "中西區",
            polygons: [[[
                [114.0, 22.0],
                [115.0, 22.0],
                [115.0, 23.0],
                [114.0, 23.0],
                [114.0, 22.0]
            ]]]
        )

        XCTAssertFalse(
            boundary.contains(latitude: 24.0, longitude: 116.0)
        )
    }
}
