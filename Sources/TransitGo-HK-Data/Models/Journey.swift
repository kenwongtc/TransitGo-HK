//
//  Journey.swift
//  TransitGo-HK-Data
//
//  Created by Ken on 7/8/2026.
//

import Foundation

struct Journey: Codable {

    let id: String
    let routeId: String

    let originStopId: String
    let destinationStopId: String

    let direction: String
    let serviceType: String

    // Normal adult full fare in Hong Kong cents.
    // Optional for backward compatibility and operators
    // not yet covered by the fare pipeline.
    let adultFullFareCents: Int?

    // Scheduled end-to-end journey time from the official route data.
    let scheduledDurationMinutes: Int?

    init(
        id: String,
        routeId: String,
        originStopId: String,
        destinationStopId: String,
        direction: String,
        serviceType: String,
        adultFullFareCents: Int? = nil,
        scheduledDurationMinutes: Int? = nil
    ) {
        self.id = id
        self.routeId = routeId
        self.originStopId = originStopId
        self.destinationStopId = destinationStopId
        self.direction = direction
        self.serviceType = serviceType
        self.adultFullFareCents = adultFullFareCents
        self.scheduledDurationMinutes = scheduledDurationMinutes
    }

}
