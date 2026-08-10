//
//  FakeMasterDataValidator.swift
//  TransitGo-HK
//
//  Created by Ken on 7/8/2026.
//

import Foundation
@testable import TransitGo_HK_Data

final class FakeMasterDataValidator: MasterDataValidating {

    private(set) var validateCalled = false

    func validate(_ data: MasterData) throws {

        validateCalled = true
    }
}
