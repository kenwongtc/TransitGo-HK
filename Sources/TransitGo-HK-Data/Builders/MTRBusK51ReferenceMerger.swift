//
//  MTRBusK51ReferenceMerger.swift
//  TransitGo-HK
//

import Foundation

enum MTRBusK51ReferenceMergeError: Error {
    case invalidReplacement(String)
    case duplicateReference(String)
}

struct MTRBusK51ReferenceMerger {

    private let k51JourneyIds: Set<String> = [
        "1871-1",
        "1871-2"
    ]

    func merge(
        existing: [OperatorStopReference],
        replacementK51References:
            [OperatorStopReference]
    ) throws -> [OperatorStopReference] {

        for reference in replacementK51References {
            guard
                reference.operatorId == "LRTFeeder",
                reference.operatorServiceType == "K51",
                k51JourneyIds.contains(
                    reference.journeyId
                )
            else {
                throw MTRBusK51ReferenceMergeError
                    .invalidReplacement(
                        reference.journeyId
                    )
            }
        }

        let merged = existing.filter {
            !(
                $0.operatorId == "LRTFeeder" &&
                k51JourneyIds.contains($0.journeyId)
            )
        } + replacementK51References

        var seenKeys: Set<String> = []

        for reference in merged {
            let key = [
                reference.operatorId,
                reference.journeyId,
                String(reference.sequence)
            ]
            .joined(separator: "|")

            guard seenKeys.insert(key).inserted else {
                throw MTRBusK51ReferenceMergeError
                    .duplicateReference(key)
            }
        }

        return merged
    }
}
