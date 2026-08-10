//
//  DataBuilderTests.swift
//  TransitGo-HK
//
//  Created by Ken on 7/8/2026.
//

import Testing
import Foundation
@testable import TransitGo_HK_Data

struct MasterDataExporterTests {

    @Test
    func testMasterDataExport() throws {

        let builder = DataBuilder()

        let masterData = try builder.build()

        let directory = FileManager.default
            .temporaryDirectory
            .appendingPathComponent("TransitGo-Test-Export")

        let exporter = MasterDataExporter()

        try exporter.export(
            masterData,
            to: directory
        )

        let files = [
            "operators.json",
            "routes.json",
            "journeys.json",
            "journeyStops.json",
            "stops.json",
            "schedules.json"
        ]

        for file in files {

            let fileURL = directory.appendingPathComponent(file)

            #expect(
                FileManager.default.fileExists(
                    atPath: fileURL.path
                )
            )
        }
    }
}
