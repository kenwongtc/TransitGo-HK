import Foundation
import Testing
@testable import TransitGo_HK_Data

struct OperatorStopReferenceCodingTests {

    @Test
    func decodesLegacyReferenceWithoutCoordinates() throws {
        let data = Data(
            """
            {
              "operatorId": "KMB",
              "journeyId": "1185-2",
              "stopId": "12897",
              "sequence": 4,
              "operatorStopId": "939FE9A08B99174C",
              "operatorServiceType": "1",
              "operatorDirection": "I"
            }
            """.utf8
        )

        let reference = try JSONDecoder().decode(
            OperatorStopReference.self,
            from: data
        )

        #expect(reference.operatorLatitude == nil)
        #expect(reference.operatorLongitude == nil)
        #expect(reference.publicStopCode == nil)
    }

    @Test
    func preservesTW371OperatorCoordinates() throws {
        let reference = OperatorStopReference(
            operatorId: "KMB",
            journeyId: "1185-2",
            stopId: "12897",
            sequence: 4,
            operatorStopId: "939FE9A08B99174C",
            publicStopCode: "TW371",
            operatorLatitude: 22.375776,
            operatorLongitude: 114.106972,
            operatorServiceType: "1",
            operatorDirection: "I"
        )

        let data = try JSONEncoder().encode(reference)
        let decoded = try JSONDecoder().decode(
            OperatorStopReference.self,
            from: data
        )

        #expect(decoded.operatorLatitude == 22.375776)
        #expect(decoded.operatorLongitude == 114.106972)
        #expect(decoded.publicStopCode == "TW371")
    }

    @Test
    func readsKnownPublicStopCode() throws {
        let codes = try KMBPublicStopCodeReader().read()

        #expect(codes["10860B611840CF22"] == "TW377")
    }
}
