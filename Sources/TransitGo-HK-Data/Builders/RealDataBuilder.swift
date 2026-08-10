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
    let validator: MasterDataValidating = MasterDataValidator()

    func build() throws -> MasterData {

        let masterData = MasterData(
            operators: try operatorBuilder.build(),
            routes: try routeBuilder.build(),
            journeys: try journeyBuilder.build(),
            journeyStops: try journeyStopBuilder.build(),
            stops: try stopBuilder.build(),
            schedules: []
        )

        try validator.validate(masterData)

        return masterData
    }
}
