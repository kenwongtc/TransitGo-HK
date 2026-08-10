//
//  Stop.swift
//  TransitGo-HK-Data
//
//  Created by Ken on 7/8/2026.
//

import Foundation

struct Stop: Codable {

    let id: String

    let nameEnglish: String
    let nameTraditional: String
    let nameSimplified: String

    let latitude: Double
    let longitude: Double

}
