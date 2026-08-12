//
//  RealDataBuilder.swift
//  TransitGo-HK
//
//  Created by Ken on 10/8/2026.
//

import Foundation

struct RealDataBuilder {

    let operatorBuilder = RealOperatorBuilder()
    let routeBuilder = RealRouteBuilder()
    let journeyBuilder = RealJourneyBuilder()
    let journeyStopBuilder = RealJourneyStopBuilder()
    let stopBuilder = RealStopBuilder()

    let operatorStopReferenceBuilder =
        KMBOperatorStopReferenceBuilder()

    let validator: MasterDataValidating =
        MasterDataValidator()

    func build() async throws -> MasterData {

        // Build the core TransitGo data once.

        let operators =
            try operatorBuilder.build()

        let routes =
            try routeBuilder.build()

        let journeys =
            try journeyBuilder.build()

        let journeyStops =
            try journeyStopBuilder.build()

        let stops =
            try stopBuilder.build()

        // Build KMB operator-specific stop references.

        let referenceResult =
            try await operatorStopReferenceBuilder.buildAll(
                routes: routes,
                journeys: journeys,
                journeyStops: journeyStops,
                stops: stops
            )

        print("")
        print("*** KMB operator stop references ***")
        print(
            "References:",
            referenceResult.references.count
        )
        print(
            "Unmatched routes:",
            referenceResult.unmatchedRoutes.count
        )
        print(
            "Unmatched journeys:",
            referenceResult.unmatchedJourneys.count
        )
        print(
            "Ambiguous journeys:",
            referenceResult.ambiguousJourneys.count
        )
        print(
            "No matching service:",
            referenceResult
                .noMatchingServiceJourneys
                .count
        )

        let masterData = MasterData(
            operators: operators,
            routes: routes,
            journeys: journeys,
            journeyStops: journeyStops,
            stops: stops,
            schedules: [],
            operatorStopReferences:
                referenceResult.references
        )

        try validator.validate(masterData)

        return masterData
    }
}
