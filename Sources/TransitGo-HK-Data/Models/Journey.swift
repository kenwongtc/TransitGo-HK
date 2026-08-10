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

}
