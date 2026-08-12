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
}
