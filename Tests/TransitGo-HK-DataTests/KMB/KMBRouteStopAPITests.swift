//
//  KMBRouteStopAPITests.swift
//  TransitGo-HK
//
//  Created by Ken on 11/8/2026.
//

import XCTest
@testable import TransitGo_HK_Data

final class KMBRouteStopAPITests: XCTestCase {


    func testBuildRoute171JointOperatorReferences() async throws {

        let allRoutes =
            try RealRouteBuilder().build()

        let allJourneys =
            try RealJourneyBuilder().build()

        let allJourneyStops =
            try RealJourneyStopBuilder().build()

        let allStops =
            try RealStopBuilder().build()

        guard let route =
            allRoutes.first(where: {
                $0.id == "8449"
            })
        else {
            XCTFail("Route 8449 not found")
            return
        }

        guard let journey =
            allJourneys.first(where: {
                $0.id == "8449-1"
            })
        else {
            XCTFail("Journey 8449-1 not found")
            return
        }

        let journeyStops =
            allJourneyStops.filter {
                $0.journeyId == journey.id
            }

        XCTAssertTrue(
            route.supportsOperator("KMB")
        )

        XCTAssertTrue(
            route.supportsOperator("CTB")
        )

        XCTAssertEqual(
            journeyStops.count,
            30
        )

        let builder =
            KMBOperatorStopReferenceBuilder()

        let result =
            try await builder.buildAll(
                routes: [route],
                journeys: [journey],
                journeyStops: journeyStops,
                stops: allStops
            )

        XCTAssertEqual(
            result.references.count,
            30
        )

        XCTAssertTrue(
            result.unmatchedRoutes.isEmpty
        )

        XCTAssertTrue(
            result.unmatchedJourneys.isEmpty
        )

        XCTAssertTrue(
            result.ambiguousJourneys.isEmpty
        )

        XCTAssertTrue(
            result.noMatchingServiceJourneys.isEmpty
        )

        let firstReference =
            result.references.first {
                $0.sequence == 1
            }

        XCTAssertNotNil(
            firstReference
        )

        XCTAssertEqual(
            firstReference?.journeyId,
            "8449-1"
        )

        XCTAssertEqual(
            firstReference?.stopId,
            "457"
        )

        XCTAssertEqual(
            firstReference?.operatorId,
            "KMB"
        )

        XCTAssertEqual(
            firstReference?.operatorStopId,
            "C95F46AD9BB057BC"
        )

        XCTAssertEqual(
            firstReference?.operatorServiceType,
            "1"
        )

        XCTAssertEqual(
            firstReference?.operatorDirection,
            "I"
        )

        let lastReference =
            result.references.first {
                $0.sequence == 30
            }

        XCTAssertEqual(
            lastReference?.stopId,
            "9561"
        )

        XCTAssertEqual(
            lastReference?.operatorStopId,
            "636F6AAF3B891E82"
        )

        XCTAssertEqual(
            lastReference?.operatorDirection,
            "I"
        )
    }

    func test39AOutboundRouteStops() async throws {

        let api = KMBRouteStopAPI()

        let records = try await api.fetch(
            route: "39A",
            direction: "outbound",
            serviceType: "1"
        )

        print("")
        print("*** KMB 39A outbound ***")
        print("Records: \(records.count)")
        print("")

        for record in records {
            print(
                "seq \(record.seq) | " +
                "stop \(record.stop) | " +
                "bound \(record.bound) | " +
                "service \(record.serviceType)"
            )
        }

        XCTAssertFalse(records.isEmpty)
    }
    
    func test39ATsuenWanCentreMapping() async throws {

        let allJourneyStops = try RealJourneyStopBuilder().build()

        let journeyStops = allJourneyStops.filter {
            $0.journeyId == "1200-1"
        }

        XCTAssertEqual(journeyStops.count, 23)

        let builder = KMBOperatorStopReferenceBuilder()

        let references = try await builder.build(
            routeNumber: "39A",
            direction: "outbound",
            serviceType: "1",
            journeyStops: journeyStops
        )

        XCTAssertEqual(references.count, 23)

        let tsuenWanCentre = references.first {
            $0.stopId == "9644"
        }

        XCTAssertNotNil(tsuenWanCentre)

        XCTAssertEqual(
            tsuenWanCentre?.operatorStopId,
            "D1CAF0CE0129B0E6"
        )

        print("")
        print("*** 39A mapping verified ***")
        print("TransitGo stop: 9644")
        print(
            "KMB stop:",
            tsuenWanCentre?.operatorStopId ?? "missing"
        )
    }
    
    func test43SDirections() async throws {

        let api = KMBRouteStopAPI()

        let outbound = try await api.fetch(
            route: "43S",
            direction: "outbound",
            serviceType: "1"
        )

        let inbound = try await api.fetch(
            route: "43S",
            direction: "inbound",
            serviceType: "1"
        )

        print("")
        print("*** KMB 43S directions ***")

        print("")
        print("OUTBOUND: \(outbound.count) stops")

        for record in outbound.prefix(5) {
            print(
                "seq \(record.seq) | " +
                "stop \(record.stop) | " +
                "bound \(record.bound)"
            )
        }

        print("")
        print("INBOUND: \(inbound.count) stops")

        for record in inbound.prefix(5) {
            print(
                "seq \(record.seq) | " +
                "stop \(record.stop) | " +
                "bound \(record.bound)"
            )
        }

        XCTAssertFalse(outbound.isEmpty)
        XCTAssertFalse(inbound.isEmpty)
    }
    
    func testBuildAllKMBStopReferences() async throws {

        let routes = try RealRouteBuilder().build()
        let journeys = try RealJourneyBuilder().build()
        let journeyStops = try RealJourneyStopBuilder().build()
        let stops = try RealStopBuilder().build()

        let builder = KMBOperatorStopReferenceBuilder()

        let result = try await builder.buildAll(
            routes: routes,
            journeys: journeys,
            journeyStops: journeyStops,
            stops: stops
        )

        print("")
        print("*** KMB full-network mapping ***")
        print("References: \(result.references.count)")
        print(
            "Uniquely matched journeys:",
            result.uniquelyMatchedJourneys
        )
        print(
            "Coordinate resolved journeys:",
            result.coordinateResolvedJourneys
        )
        print(
            "Unmatched routes:",
            result.unmatchedRoutes.count
        )
        print(
            "Unmatched journeys:",
            result.unmatchedJourneys.count
        )
        print(
            "Ambiguous journeys:",
            result.ambiguousJourneys.count
        )
        print(
            "No matching service:",
            result.noMatchingServiceJourneys.count
        )
        print(
            "Identical-sequence resolved journeys:",
            result.identicalSequenceResolvedJourneys
        )
        print(
            "Position resolved journeys:",
            result.positionResolvedJourneys
        )
        
        print(
            "Alignment resolved journeys:",
            result.alignmentResolvedJourneys
        )
        
        print("")
        print("*** Alignment resolved journeys ***")

        print("")
        print("*** Remaining no-match journey count differences ***")

        let routeAPI = KMBRouteAPI()
        let routeStopAPI = KMBRouteStopAPI()

        let kmbRoutes = try await routeAPI.fetchAll()

        let kmbRoutesByNumber = Dictionary(
            grouping: kmbRoutes,
            by: \.route
        )

        var differenceCounts: [Int: Int] = [:]

        for item in result.noMatchingServiceJourneys {

            guard let apiRoutes = kmbRoutesByNumber[item.routeNumber] else {
                continue
            }

            let matchingRoutes = apiRoutes.filter {
                $0.bound == item.bound
            }

            var closestDifference: Int?

            for apiRoute in matchingRoutes {

                let direction =
                    item.bound == "I"
                        ? "inbound"
                        : "outbound"

                let apiStops = try await routeStopAPI.fetch(
                    route: apiRoute.route,
                    direction: direction,
                    serviceType: apiRoute.serviceType
                )

                let difference = abs(
                    item.transitGoCount - apiStops.count
                )

                if closestDifference == nil ||
                    difference < closestDifference! {

                    closestDifference = difference
                }
            }

            if let closestDifference {
                differenceCounts[
                    closestDifference,
                    default: 0
                ] += 1
            }
        }

        for difference in differenceCounts.keys.sorted() {
            print(
                "difference",
                difference,
                ":",
                differenceCounts[difference] ?? 0,
                "journeys"
            )
        }
        
        for item in result.alignmentResolvedDetails {

            print("")

            print(
                item.routeNumber,
                "|",
                item.journeyId,
                "| bound",
                item.bound,
                "| service",
                item.serviceType
            )

            print(
                "  matched:",
                item.matchedCount
            )

            print(
                "  TransitGo-only:",
                item.transitGoOnlyCount
            )

            print(
                "  KMB-only:",
                item.kmbOnlyCount
            )

            print(
                "  coverage:",
                String(
                    format: "%.1f%%",
                    item.coverage * 100
                )
            )

            print(
                "  average distance:",
                String(
                    format: "%.1f m",
                    item.averageDistance
                )
            )

            print(
                "  maximum distance:",
                String(
                    format: "%.1f m",
                    item.maximumDistance
                )
            )
        }
        
        print("")
        print("*** Alignment resolved journeys ***")

        for item in result.alignmentResolvedDetails {

            print("")

            print(
                item.routeNumber,
                "|",
                item.journeyId,
                "| bound",
                item.bound,
                "| service",
                item.serviceType
            )

            print(
                "  matched:",
                item.matchedCount
            )

            print(
                "  TransitGo-only:",
                item.transitGoOnlyCount
            )

            print(
                "  KMB-only:",
                item.kmbOnlyCount
            )

            print(
                "  coverage:",
                String(
                    format: "%.1f%%",
                    item.coverage * 100
                )
            )

            print(
                "  average distance:",
                String(
                    format: "%.1f m",
                    item.averageDistance
                )
            )

            print(
                "  maximum distance:",
                String(
                    format: "%.1f m",
                    item.maximumDistance
                )
            )
        }
        
        print("")
        print("*** First unmatched routes ***")

        for item in result.unmatchedRoutes.prefix(10) {
            print(item)
        }

        print("")
        print("*** First unmatched journeys ***")

        for item in result.unmatchedJourneys.prefix(10) {
            print(item)
        }

        print("")
        print("*** Alignment resolved journeys ***")

        for item in result.alignmentResolvedDetails {

            print("")
            print(
                item.routeNumber,
                "|",
                item.journeyId,
                "| bound",
                item.bound,
                "| service",
                item.serviceType
            )

            print(
                "  matched:",
                item.matchedCount
            )

            print(
                "  TransitGo-only:",
                item.transitGoOnlyCount
            )

            print(
                "  KMB-only:",
                item.kmbOnlyCount
            )

            print(
                "  coverage:",
                String(
                    format: "%.1f%%",
                    item.coverage * 100
                )
            )

            print(
                "  average distance:",
                String(
                    format: "%.1f m",
                    item.averageDistance
                )
            )

            print(
                "  maximum distance:",
                String(
                    format: "%.1f m",
                    item.maximumDistance
                )
            )
        }
        
        print("")
        print("*** Remaining ambiguous journeys ***")
    
        for item in result.ambiguousJourneys {

            print("")
            print(
                item.routeNumber,
                "|",
                item.journeyId,
                "| bound",
                item.bound,
                "| stops",
                item.transitGoCount
            )

            print(
                "  identical KMB stop sequences:",
                item.identicalStopSequences
            )

            for candidate in item.candidates {

                let distance: String

                if candidate.averageDistance.isFinite {
                    distance = String(
                        format: "%.1f m",
                        candidate.averageDistance
                    )
                } else {
                    distance = "unavailable"
                }

                print(
                    "  service",
                    candidate.serviceType,
                    "| average",
                    distance,
                    "| position wins",
                    candidate.positionWins
                )
            }

            let finiteCandidates = item.candidates
                .filter {
                    $0.averageDistance.isFinite
                }
                .sorted {
                    $0.averageDistance <
                        $1.averageDistance
                }

            if finiteCandidates.count >= 2 {

                let best = finiteCandidates[0]
                let second = finiteCandidates[1]

                let ratio =
                    best.averageDistance /
                    second.averageDistance

                print(
                    "  best/second ratio:",
                    String(
                        format: "%.3f",
                        ratio
                    )
                )
            }
        }

        print("")
        print("*** First no matching service ***")

        for item in result
            .noMatchingServiceJourneys
            .prefix(10) {

            let routeInfo =
                "\(item.routeNumber) | \(item.journeyId)"

            let boundInfo =
                "bound \(item.bound)"

            let countInfo =
                "TransitGo \(item.transitGoCount)"

            print(
                routeInfo,
                "|",
                boundInfo,
                "|",
                countInfo
            )
        }

        XCTAssertFalse(
            result.references.isEmpty
        )
        
        print("")
        print("*** Best rejected alignments ***")

        for item in result.rejectedAlignmentDetails {

            let difference =
                abs(
                    item.transitGoCount -
                    item.kmbCount
                )

            print(
                item.routeNumber,
                "|",
                item.journeyId,
                "| service",
                item.serviceType,
                "| difference",
                difference,
                "| matched",
                item.matchedCount,
                "| gaps",
                item.transitGoOnlyCount +
                    item.kmbOnlyCount,
                "| coverage",
                String(
                    format: "%.1f%%",
                    item.coverage * 100
                ),
                "| avg",
                String(
                    format: "%.1f m",
                    item.averageDistance
                ),
                "| max",
                String(
                    format: "%.1f m",
                    item.maximumDistance
                )
            )
        }
        
        print("")
        print("*** Proposed second-tier alignments ***")

        let secondTier = result.rejectedAlignmentDetails.filter {
            $0.coverage >= 0.90 &&
            ($0.transitGoOnlyCount + $0.kmbOnlyCount) <= 3 &&
            $0.averageDistance <= 400 &&
            $0.maximumDistance <= 700
        }

        print(
            "Second-tier candidates:",
            secondTier.count
        )

        for item in secondTier {

            print(
                item.routeNumber,
                "|",
                item.journeyId,
                "| service",
                item.serviceType,
                "| matched",
                item.matchedCount,
                "| gaps",
                item.transitGoOnlyCount +
                    item.kmbOnlyCount,
                "| coverage",
                String(
                    format: "%.1f%%",
                    item.coverage * 100
                ),
                "| avg",
                String(
                    format: "%.1f m",
                    item.averageDistance
                ),
                "| max",
                String(
                    format: "%.1f m",
                    item.maximumDistance
                )
            )
        }
        
        print("******************************************")

    }
    
    func testKMBTsuenWanCentreStop() async throws {

        let api = KMBStopAPI()

        let stop = try await api.fetch(
            stopId: "D1CAF0CE0129B0E6"
        )

        print("")
        print("*** KMB stop diagnostic ***")
        print("ID: \(stop.stop)")
        print("English: \(stop.nameEnglish)")
        print("Traditional: \(stop.nameTraditional)")
        print("Simplified: \(stop.nameSimplified)")
        print("Latitude: \(stop.latitude)")
        print("Longitude: \(stop.longitude)")

        XCTAssertEqual(
            stop.stop,
            "D1CAF0CE0129B0E6"
        )

        XCTAssertEqual(
            stop.nameEnglish.uppercased(),
            "TSUEN WAN CENTRE"
        )
    }
    
    func test224XServiceTypeMatching() async throws {

        let journeyId = "1066-1"

        let allJourneyStops =
            try RealJourneyStopBuilder().build()

        let allStops =
            try RealStopBuilder().build()

        let localJourneyStops = allJourneyStops
            .filter {
                $0.journeyId == journeyId
            }
            .sorted {
                $0.sequence < $1.sequence
            }

        let localStopLookup = Dictionary(
            uniqueKeysWithValues: allStops.map {
                ($0.id, $0)
            }
        )

        let routeStopAPI = KMBRouteStopAPI()
        let stopAPI = KMBStopAPI()

        // Fetch KMB stop metadata once.
        let kmbStops = try await stopAPI.fetchAll()

        let kmbStopLookup = Dictionary(
            uniqueKeysWithValues: kmbStops.map {
                ($0.stop, $0)
            }
        )

        print("")
        print("*** 224X service comparison ***")
        print(
            "TransitGo stops:",
            localJourneyStops.count
        )

        for serviceType in ["1", "3"] {

            let apiStops = try await routeStopAPI.fetch(
                route: "224X",
                direction: "outbound",
                serviceType: serviceType
            )

            var distances: [Double] = []
            var within100Meters = 0
            var compared = 0

            for apiStop in apiStops {

                guard
                    let sequence = apiStop.sequence,
                    let localJourneyStop =
                        localJourneyStops.first(
                            where: {
                                $0.sequence == sequence
                            }
                        ),
                    let localStop =
                        localStopLookup[
                            localJourneyStop.stopId
                        ],
                    let kmbStop =
                        kmbStopLookup[apiStop.stop],
                    let kmbLatitude =
                        kmbStop.latitudeValue,
                    let kmbLongitude =
                        kmbStop.longitudeValue
                else {
                    continue
                }

                let distance = distanceMeters(
                    latitude1: localStop.latitude,
                    longitude1: localStop.longitude,
                    latitude2: kmbLatitude,
                    longitude2: kmbLongitude
                )

                distances.append(distance)
                compared += 1

                if distance <= 100 {
                    within100Meters += 1
                }
            }

            let averageDistance: Double

            if distances.isEmpty {
                averageDistance = 0
            } else {
                averageDistance =
                    distances.reduce(0, +) /
                    Double(distances.count)
            }

            let maximumDistance =
                distances.max() ?? 0

            print("")
            print(
                "Service \(serviceType)"
            )

            print(
                "KMB stops:",
                apiStops.count
            )

            print(
                "Compared:",
                compared
            )

            print(
                "Within 100 m:",
                within100Meters
            )

            print(
                "Average distance:",
                String(
                    format: "%.1f m",
                    averageDistance
                )
            )

            print(
                "Maximum distance:",
                String(
                    format: "%.1f m",
                    maximumDistance
                )
            )
        }
    }
    
    private func distanceMeters(
        latitude1: Double,
        longitude1: Double,
        latitude2: Double,
        longitude2: Double
    ) -> Double {

        let earthRadius = 6_371_000.0

        let lat1 = latitude1 * .pi / 180
        let lat2 = latitude2 * .pi / 180

        let deltaLat =
            (latitude2 - latitude1) *
            .pi / 180

        let deltaLon =
            (longitude2 - longitude1) *
            .pi / 180

        let a =
            sin(deltaLat / 2) *
            sin(deltaLat / 2) +
            cos(lat1) *
            cos(lat2) *
            sin(deltaLon / 2) *
            sin(deltaLon / 2)

        let c =
            2 * atan2(
                sqrt(a),
                sqrt(1 - a)
            )

        return earthRadius * c
    }
    
    func test26InboundServiceDiagnostic() async throws {

        let routeAPI = KMBRouteAPI()
        let routeStopAPI = KMBRouteStopAPI()

        let routes = try await routeAPI.fetchAll()

        let route26Inbound = routes
            .filter {
                $0.route == "26" &&
                $0.bound == "I"
            }
            .sorted {
                $0.serviceType < $1.serviceType
            }

        print("")
        print("*** KMB 26 inbound services ***")

        for route in route26Inbound {

            let stops = try await routeStopAPI.fetch(
                route: route.route,
                direction: "inbound",
                serviceType: route.serviceType
            )

            print(
                "service",
                route.serviceType,
                "| KMB stops",
                stops.count
            )
        }

        print("")
        print("*** TransitGo 26 / 1096-2 ***")

        let journeyStops =
            try RealJourneyStopBuilder()
                .build()
                .filter {
                    $0.journeyId == "1096-2"
                }
                .sorted {
                    $0.sequence < $1.sequence
                }

        print(
            "TransitGo stops:",
            journeyStops.count
        )
    }
    
    func test26InboundStopSequenceAlignment() async throws {

        let routeStopAPI = KMBRouteStopAPI()
        let stopAPI = KMBStopAPI()

        let allJourneyStops =
            try RealJourneyStopBuilder().build()

        let allStops =
            try RealStopBuilder().build()

        let localJourneyStops = allJourneyStops
            .filter {
                $0.journeyId == "1096-2"
            }
            .sorted {
                $0.sequence < $1.sequence
            }

        let kmbStops = try await stopAPI.fetchAll()

        let localStopLookup = Dictionary(
            uniqueKeysWithValues: allStops.map {
                ($0.id, $0)
            }
        )

        let kmbStopLookup = Dictionary(
            uniqueKeysWithValues: kmbStops.map {
                ($0.stop, $0)
            }
        )

        let apiStops = try await routeStopAPI.fetch(
            route: "26",
            direction: "inbound",
            serviceType: "1"
        )

        let aligner = KMBStopSequenceAligner()

        let alignment = aligner.align(
            transitGoStops: localJourneyStops,
            kmbStops: apiStops,
            localStopLookup: localStopLookup,
            kmbStopLookup: kmbStopLookup
        )

        print("")
        print("*** Route 26 inbound alignment ***")
        print("TransitGo stops:", localJourneyStops.count)
        print("KMB stops:", apiStops.count)
        print("Matched pairs:", alignment.matchedPairs.count)
        print("TransitGo-only:", alignment.transitGoOnly.count)
        print("KMB-only:", alignment.kmbOnly.count)

        print("")
        print("*** TransitGo-only stops ***")

        for journeyStop in alignment.transitGoOnly {

            if let stop =
                localStopLookup[journeyStop.stopId] {

                print(
                    "seq",
                    journeyStop.sequence,
                    "|",
                    journeyStop.stopId,
                    "|",
                    stop.nameEnglish
                )
            }
        }

        print("")
        print("*** KMB-only stops ***")

        for apiStop in alignment.kmbOnly {

            if let stop =
                kmbStopLookup[apiStop.stop] {

                print(
                    "seq",
                    apiStop.seq,
                    "|",
                    apiStop.stop,
                    "|",
                    stop.nameEnglish
                )
            }
        }

        print("")
        print("*** Largest matched distances ***")

        let largestMatches = alignment.matchedPairs
            .sorted {
                $0.distanceMeters >
                    $1.distanceMeters
            }
            .prefix(10)

        for match in largestMatches {

            let localStop =
                localStopLookup[
                    match.transitGoStop.stopId
                ]

            let remoteStop =
                kmbStopLookup[
                    match.kmbStop.stop
                ]

            print(
                "TransitGo seq",
                match.transitGoStop.sequence,
                localStop?.nameEnglish ?? "?",
                "<-> KMB seq",
                match.kmbStop.seq,
                remoteStop?.nameEnglish ?? "?",
                "|",
                String(
                    format: "%.1f m",
                    match.distanceMeters
                )
            )
        }

        XCTAssertEqual(
            localJourneyStops.count,
            28
        )

        XCTAssertEqual(
            apiStops.count,
            27
        )
        
    }
    
    
}
