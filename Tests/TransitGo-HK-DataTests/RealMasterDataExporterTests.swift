//
//  RealMasterDataExporterTests.swift
//  TransitGo-HK
//
//  Created by Ken on 10/8/2026.
//

import XCTest
@testable import TransitGo_HK_Data

final class RealMasterDataExporterTests: XCTestCase {

    func testExportRealMasterData() async throws {
        let masterData = try await RealDataBuilder().build()
        
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(
                "TransitGo-HK-RealMasterData-\(UUID().uuidString)"
            )

        try MasterDataExporter().export(
            masterData,
            to: directory
        )

        let expectedFiles = [
            "operators.json",
            "routes.json",
            "journeys.json",
            "journeyStops.json",
            "stops.json",
            "schedules.json"
        ]

        for filename in expectedFiles {
            let url = directory.appendingPathComponent(filename)

            XCTAssertTrue(
                FileManager.default.fileExists(atPath: url.path),
                "\(filename) was not exported"
            )
        }

        let routesData = try Data(
            contentsOf: directory.appendingPathComponent("routes.json")
        )

        let routes = try JSONDecoder().decode(
            [Route].self,
            from: routesData
        )

        XCTAssertEqual(routes.count, 1609)

        try? FileManager.default.removeItem(at: directory)
    }
}
