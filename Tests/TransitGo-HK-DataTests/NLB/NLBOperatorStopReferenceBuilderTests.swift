//
//  NLBOperatorStopReferenceBuilderTests.swift
//  TransitGo-HK
//

import XCTest
@testable import TransitGo_HK_Data

final class NLBOperatorStopReferenceBuilderTests:
    XCTestCase {

    func testBuildAllAggregatesNLBJourneys() {

        let result = builder.buildAll(
            routes: [route()],
            journeys: [journey()],
            journeyStops: journeyStops(),
            stops: localStops(),
            nlbRoutes: [nlbRoute(id: "1")],
            nlbStopsByRouteId: [
                "1": matchingNLBStops()
            ]
        )

        XCTAssertEqual(result.matchedJourneys, 1)
        XCTAssertEqual(result.references.count, 2)
        XCTAssertTrue(result.unmatchedRoutes.isEmpty)
        XCTAssertTrue(result.unmatchedJourneys.isEmpty)
        XCTAssertTrue(result.ambiguousJourneys.isEmpty)
        XCTAssertTrue(result.rejectedJourneys.isEmpty)
    }

    func testBuildAllReportsUnmatchedRoute() {

        let result = builder.buildAll(
            routes: [route()],
            journeys: [journey()],
            journeyStops: journeyStops(),
            stops: localStops(),
            nlbRoutes: [],
            nlbStopsByRouteId: [:]
        )

        XCTAssertTrue(result.references.isEmpty)
        XCTAssertEqual(
            result.unmatchedRoutes,
            ["route-1 | 1"]
        )
    }

    func testSelectsBestVariantAndBuildsReferences() {

        let result = builder.build(
            route: route(),
            journey: journey(),
            journeyStops: journeyStops(),
            stops: localStops(),
            nlbRoutes: [
                nlbRoute(id: "1"),
                nlbRoute(id: "2")
            ],
            nlbStopsByRouteId: [
                "1": matchingNLBStops(),
                "2": distantNLBStops()
            ]
        )

        XCTAssertEqual(result?.routeId, "1")
        XCTAssertEqual(result?.references.count, 2)
        XCTAssertEqual(
            result?.references.map(\.operatorStopId),
            ["nlb-a", "nlb-b"]
        )
        XCTAssertTrue(
            result?.references.allSatisfy {
                $0.operatorId == "NLB" &&
                $0.operatorServiceType == "1" &&
                $0.operatorDirection == "outbound"
            } ?? false
        )
    }

    func testPrefersCandidateWithExactEndpoints() {

        let result = builder.build(
            route: route(),
            journey: journey(),
            journeyStops: journeyStops(),
            stops: localStops(),
            nlbRoutes: [
                nlbRoute(id: "exact"),
                nlbRoute(id: "extra-leading")
            ],
            nlbStopsByRouteId: [
                "exact": matchingNLBStops(),
                "extra-leading": [
                    nlbStop(
                        id: "extra",
                        latitude: "22.2550"
                    )
                ] + matchingNLBStops()
            ]
        )

        XCTAssertEqual(result?.routeId, "exact")
        XCTAssertEqual(result?.isAmbiguous, false)
    }

    func testRejectsWeakCoverage() {

        let result = builder.build(
            route: route(),
            journey: journey(),
            journeyStops: journeyStops(),
            stops: localStops(),
            nlbRoutes: [nlbRoute(id: "1")],
            nlbStopsByRouteId: [
                "1": [matchingNLBStops()[0]]
            ]
        )

        XCTAssertNil(result)
    }

    func testRejectsAmbiguousVariants() {

        let result = builder.build(
            route: route(),
            journey: journey(),
            journeyStops: journeyStops(),
            stops: localStops(),
            nlbRoutes: [
                nlbRoute(id: "1"),
                nlbRoute(id: "2")
            ],
            nlbStopsByRouteId: [
                "1": matchingNLBStops(),
                "2": matchingNLBStops()
            ]
        )

        XCTAssertEqual(result?.isAmbiguous, true)
    }

    private let builder =
        NLBOperatorStopReferenceBuilder()

    private func route() -> Route {
        Route(
            id: "route-1",
            number: "1",
            operatorIds: ["NLB"],
            originEnglish: "Origin",
            originTraditional: "Origin",
            originSimplified: "Origin",
            destinationEnglish: "Destination",
            destinationTraditional: "Destination",
            destinationSimplified: "Destination"
        )
    }

    private func journey() -> Journey {
        Journey(
            id: "journey-1",
            routeId: "route-1",
            originStopId: "local-a",
            destinationStopId: "local-b",
            direction: "outbound",
            serviceType: "1"
        )
    }

    private func journeyStops() -> [JourneyStop] {
        [
            JourneyStop(
                journeyId: "journey-1",
                stopId: "local-a",
                sequence: 1
            ),
            JourneyStop(
                journeyId: "journey-1",
                stopId: "local-b",
                sequence: 2
            )
        ]
    }

    private func localStops() -> [Stop] {
        [
            stop(id: "local-a", latitude: 22.2600),
            stop(id: "local-b", latitude: 22.2610)
        ]
    }

    private func matchingNLBStops()
        -> [NLBRouteStopRecord] {
        [
            nlbStop(id: "nlb-a", latitude: "22.2600"),
            nlbStop(id: "nlb-b", latitude: "22.2610")
        ]
    }

    private func distantNLBStops()
        -> [NLBRouteStopRecord] {
        [
            nlbStop(id: "far-a", latitude: "22.2800"),
            nlbStop(id: "far-b", latitude: "22.2810")
        ]
    }

    private func nlbRoute(
        id: String
    ) -> NLBRouteRecord {
        NLBRouteRecord(
            routeId: id,
            routeNumber: "1",
            routeNameTraditional: "Origin > Destination",
            routeNameSimplified: "Origin > Destination",
            routeNameEnglish: "Origin > Destination",
            isOvernightRoute: 0,
            isSpecialRoute: 0
        )
    }

    private func stop(
        id: String,
        latitude: Double
    ) -> Stop {
        Stop(
            id: id,
            nameEnglish: id,
            nameTraditional: id,
            nameSimplified: id,
            latitude: latitude,
            longitude: 114
        )
    }

    private func nlbStop(
        id: String,
        latitude: String
    ) -> NLBRouteStopRecord {
        NLBRouteStopRecord(
            stopId: id,
            stopNameTraditional: id,
            stopNameSimplified: id,
            stopNameEnglish: id,
            stopLocationTraditional: id,
            stopLocationSimplified: id,
            stopLocationEnglish: id,
            latitude: latitude,
            longitude: "114"
        )
    }
}
