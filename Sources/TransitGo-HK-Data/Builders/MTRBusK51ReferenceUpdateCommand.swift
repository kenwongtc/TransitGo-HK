//
//  MTRBusK51ReferenceUpdateCommand.swift
//  TransitGo-HK
//

import Foundation

enum MTRBusK51ReferenceUpdateCommandError: Error {
    case incompleteBuild(Int)
}

struct MTRBusK51ReferenceUpdateCommandResult {
    let buildResults:
        [MTRBusOperatorStopReferenceBuildResult]
    let stageResult:
        MTRBusK51ReferenceUpdateStageResult
    let outputDirectory: URL
}

struct MTRBusK51ReferenceUpdateCommand {

    func run(
        in rootDirectory: URL
    ) async throws
        -> MTRBusK51ReferenceUpdateCommandResult {

        let inputDirectory = rootDirectory
            .appendingPathComponent("Dataset")
        let outputDirectory = rootDirectory
            .appendingPathComponent("K51Update")

        let routes: [Route] = try decode(
            "routes.json",
            from: inputDirectory
        )
        let journeys: [Journey] = try decode(
            "journeys.json",
            from: inputDirectory
        )
        let journeyStops: [JourneyStop] = try decode(
            "journey_stops.json",
            from: inputDirectory
        )
        let stops: [Stop] = try decode(
            "stops.json",
            from: inputDirectory
        )
        let existingReferences:
            [OperatorStopReference] = try decode(
                "operator_stop_references.json",
                from: inputDirectory
            )
        let currentVersion: DataVersion = try decode(
            "dataset_info.json",
            from: inputDirectory
        )

        let buildResults = try await
            MTRBusOperatorStopReferenceBuilder()
                .buildK51(
                    routes: routes,
                    journeys: journeys,
                    journeyStops: journeyStops,
                    stops: stops
                )

        guard buildResults.count == 2 else {
            throw MTRBusK51ReferenceUpdateCommandError
                .incompleteBuild(buildResults.count)
        }

        let replacementReferences = buildResults
            .flatMap(\.references)

        let stageResult = try
            MTRBusK51ReferenceUpdateStager().stage(
                existingReferences:
                    existingReferences,
                replacementK51References:
                    replacementReferences,
                currentVersion: currentVersion,
                to: outputDirectory
            )

        return MTRBusK51ReferenceUpdateCommandResult(
            buildResults: buildResults,
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
