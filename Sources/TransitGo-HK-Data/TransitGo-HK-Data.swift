 // The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

@main
struct TransitGo_Data {

    static func main() {

        print("""
        ===========================
        TransitGo-HK Data Generator
        ===========================
        """)

        do {
            let masterData = try RealDataBuilder().build()

            let outputDirectory = URL(
                fileURLWithPath: FileManager.default.currentDirectoryPath
            )
            .appendingPathComponent("Output")

            try MasterDataExporter().export(
                masterData,
                to: outputDirectory
            )

            print("Export completed.")
            print("Output: \(outputDirectory.path)")
            print("Operators: \(masterData.operators.count)")
            print("Routes: \(masterData.routes.count)")
            print("Journeys: \(masterData.journeys.count)")
            print("JourneyStops: \(masterData.journeyStops.count)")
            print("Stops: \(masterData.stops.count)")
            print("Schedules: \(masterData.schedules.count)")

        } catch {
            print("ERROR: \(error)")
        }
    }
}
