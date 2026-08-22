//
//  JourneyShapeUpdateCommand.swift
//  TransitGo-HK
//

import Foundation

enum JourneyShapeUpdateCommandError: Error {
    case insufficientCoverage(Int)
}

struct JourneyShapeUpdateCommandResult {
    let stageResult: JourneyShapeUpdateStageResult
    let outputDirectory: URL
}

struct JourneyShapeUpdateCommand {

    func run(
        in rootDirectory: URL
    ) async throws -> JourneyShapeUpdateCommandResult {

        let inputDirectory = rootDirectory
            .appendingPathComponent("Dataset")
        let outputDirectory = rootDirectory
            .appendingPathComponent("JourneyShapeUpdate")

        let journeys: [Journey] = try decode(
            "journeys.json",
            from: inputDirectory
        )
        let currentVersion: DataVersion = try decode(
            "dataset_info.json",
            from: inputDirectory
        )

        let officialShapes = try await
            CSDIBusRouteShapeReader().fetch()
        let shapes = JourneyShapeBuilder().build(
            journeys: journeys,
            officialShapes: officialShapes
        )

        guard shapes.count >= 2_200 else {
            throw JourneyShapeUpdateCommandError
                .insufficientCoverage(shapes.count)
        }

        let stageResult = try
            JourneyShapeUpdateStager().stage(
                shapes: shapes,
                currentVersion: currentVersion,
                to: outputDirectory
            )

        return JourneyShapeUpdateCommandResult(
            stageResult: stageResult,
            outputDirectory: outputDirectory
        )
    }

    private func decode<T: Decodable>(
        _ filename: String,
        from directory: URL
    ) throws -> T {

        try JSONDecoder().decode(
            T.self,
            from: Data(
                contentsOf:
                    directory.appendingPathComponent(
                        filename
                    )
            )
        )
    }
}
