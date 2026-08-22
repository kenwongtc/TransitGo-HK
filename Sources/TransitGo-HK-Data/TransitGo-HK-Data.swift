import Foundation

@main
struct TransitGo_Data {

    static func main() async {

        print("""
        ===========================
        TransitGo-HK Data Generator
        ===========================
        """)

        do {
            let rootDirectory = URL(
                fileURLWithPath:
                    FileManager.default
                        .currentDirectoryPath
            )

            if CommandLine.arguments.contains(
                "--stage-nlb-update"
            ) {
                let result = try await
                    NLBReferenceUpdateCommand()
                        .run(in: rootDirectory)

                print("")
                print("*** NLB update staged ***")
                print(
                    "NLB references:",
                    result.stageResult
                        .nlbReferenceCount
                )
                print(
                    "Matched journeys:",
                    result.buildResult
                        .matchedJourneys
                )
                print(
                    "Ambiguous journeys:",
                    result.buildResult
                        .ambiguousJourneys.count
                )
                print(
                    "Rejected journeys:",
                    result.buildResult
                        .rejectedJourneys.count
                )
                print(
                    "Total references:",
                    result.stageResult
                        .referenceCount
                )
                print(
                    "Version:",
                    result.stageResult
                        .version.version
                )
                print(
                    "Output:",
                    result.outputDirectory.path
                )
                return
            }

            if CommandLine.arguments.contains(
                "--stage-k51-update"
            ) {
                let result = try await
                    MTRBusK51ReferenceUpdateCommand()
                        .run(in: rootDirectory)

                print("")
                print("*** K51 update staged ***")

                for buildResult in
                    result.buildResults {
                    print(
                        buildResult.references.first?
                            .journeyId ?? "unknown",
                        "| direction:",
                        buildResult.direction,
                        "| references:",
                        buildResult.references.count,
                        "| coverage:",
                        buildResult.coverage
                    )
                }

                print(
                    "K51 references:",
                    result.stageResult
                        .k51ReferenceCount
                )
                print(
                    "Total references:",
                    result.stageResult.referenceCount
                )
                print(
                    "Version:",
                    result.stageResult.version.version
                )
                print(
                    "Output:",
                    result.outputDirectory.path
                )
                return
            }

            let masterData =
                try await RealDataBuilder().build()

            let outputDirectory =
                rootDirectory.appendingPathComponent(
                    "Output"
                )

            try MasterDataExporter().export(
                masterData,
                to: outputDirectory
            )

            print("Export completed.")
            print(
                "Output:",
                outputDirectory.path
            )

            print(
                "Operators:",
                masterData.operators.count
            )

            print(
                "Routes:",
                masterData.routes.count
            )

            print(
                "Journeys:",
                masterData.journeys.count
            )

            print(
                "JourneyStops:",
                masterData.journeyStops.count
            )

            print(
                "Stops:",
                masterData.stops.count
            )

            print(
                "Schedules:",
                masterData.schedules.count
            )

            print(
                "Operator stop references:",
                masterData
                    .operatorStopReferences
                    .count
            )

        } catch {
            print(
                "ERROR:",
                error
            )
        }
    }
}
