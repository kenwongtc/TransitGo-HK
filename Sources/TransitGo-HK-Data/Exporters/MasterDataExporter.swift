//
//  MasterDataExporter.swift
//  TransitGo-HK
//
//  Created by Ken on 7/8/2026.
//

import Foundation

struct MasterDataExporter {

    func export(
        _ data: MasterData,
        to directory: URL
    ) throws {

        try FileManager.default
            .createDirectory(
                at: directory,
                withIntermediateDirectories: true
            )

        try encode(data.operators, filename: "operators.json", directory: directory)
        try encode(data.routes, filename: "routes.json", directory: directory)
        try encode(data.journeys, filename: "journeys.json", directory: directory)
        try encode(data.journeyStops, filename: "journeyStops.json", directory: directory)
        try encode(data.stops, filename: "stops.json", directory: directory)
        try encode(data.schedules, filename: "schedules.json", directory: directory)
    }


    private func encode<T: Encodable>(
        _ value: T,
        filename: String,
        directory: URL
    ) throws {

        let encoder = JSONEncoder()

        encoder.outputFormatting = [
            .prettyPrinted,
            .sortedKeys
        ]

        let data = try encoder.encode(value)

        let url = directory.appendingPathComponent(filename)

        try data.write(to: url)
    }
}
