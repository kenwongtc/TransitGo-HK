//
//  OperatorStopReference.swift
//  TransitGo-HK
//
//  Created by Ken on 11/8/2026.
//

import Foundation

struct OperatorStopReference: Codable {

    let operatorId: String

    // TransitGo journey
    let journeyId: String

    // TransitGo canonical stop
    let stopId: String

    // Position within this journey
    let sequence: Int

    // Operator-specific stop ID used by its API
    let operatorStopId: String

    // Operator-specific service variant.
    // For KMB this is the numeric service_type,
    // stored as text so the model remains operator-neutral.
    let operatorServiceType: String
}
