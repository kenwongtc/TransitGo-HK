//
//  OperatorBuilder.swift
//  TransitGo-HK-Data
//
//  Created by Ken on 7/8/2026.
//

import Foundation

struct OperatorBuilder {

    let reader = OperatorReader()
    let validator = OperatorValidator()

    func build() throws -> [Operator] {

        let operators = try reader.read()

        validator.validate(operators)

        return operators
    }

}
