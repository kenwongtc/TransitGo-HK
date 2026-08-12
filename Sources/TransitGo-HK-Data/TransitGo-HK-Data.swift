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
            let masterData =
                try await RealDataBuilder().build()

            let outputDirectory = URL(
                fileURLWithPath:
                    FileManager.default.currentDirectoryPath
            )
            .appendingPathComponent("Output")

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
