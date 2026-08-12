//
//  KMBRouteAPITests.swift
//  TransitGo-HK
//
//  Created by Ken on 11/8/2026.
//

import XCTest
@testable import TransitGo_HK_Data

final class KMBRouteAPITests: XCTestCase {

    func testFetchRoutes() async throws {

        let api = KMBRouteAPI()

        let routes = try await api.fetchAll()

        XCTAssertFalse(routes.isEmpty)

        print("")
        print("*** KMB route API ***")
        print("Total records: \(routes.count)")

        let route39A = routes.filter {
            $0.route == "39A"
        }

        print("")
        print("*** 39A ***")

        for route in route39A {
            print(
                "route \(route.route) | " +
                "bound \(route.bound) | " +
                "service \(route.serviceType) | " +
                "\(route.origEnglish) -> " +
                "\(route.destEnglish)"
            )
        }

        let route43S = routes.filter {
            $0.route == "43S"
        }

        print("")
        print("*** 43S ***")

        for route in route43S {
            print(
                "route \(route.route) | " +
                "bound \(route.bound) | " +
                "service \(route.serviceType) | " +
                "\(route.origEnglish) -> " +
                "\(route.destEnglish)"
            )
        }
        
        
    }
}
