//
//  MasterDataValidationError.swift
//  TransitGo-HK
//
//  Created by Ken on 7/8/2026.
//

enum MasterDataValidationError: Error {

    case missingOperatorReference(String)
    case missingRouteReference(String)
    case missingJourneyReference(String)
    case missingStopReference(String)
}
