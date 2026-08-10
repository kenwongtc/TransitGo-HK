//
//  DataVersionManagerTests.swift
//  TransitGo-HK
//
//  Created by Ken on 7/8/2026.
//

import Testing
@testable import TransitGo_HK_Data

struct DataVersionManagerTests {

    @Test
    func testNeedsUpdate() {

        let manager = DataVersionManager()

        let local = DataVersion(
            version: "2026.08.01",
            generatedAt: "2026-08-01"
        )

        let sameRemote = DataVersion(
            version: "2026.08.01",
            generatedAt: "2026-08-01"
        )

        let newRemote = DataVersion(
            version: "2026.08.07",
            generatedAt: "2026-08-07"
        )

        #expect(
            manager.needsUpdate(
                local: local,
                remote: sameRemote
            ) == false
        )

        #expect(
            manager.needsUpdate(
                local: local,
                remote: newRemote
            ) == true
        )
    }
}
