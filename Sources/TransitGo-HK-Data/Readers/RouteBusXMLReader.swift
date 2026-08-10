//
//  RouteBusXMLReader.swift
//  TransitGo-HK
//
//  Created by Ken on 9/8/2026.
//

import Foundation

struct RouteBusRecord: Sendable {
    let routeID: String
    let companyCode: String
    let number: String
    let serviceMode: String
}

struct RouteBusXMLReader {

    func read(from url: URL) throws -> [RouteBusRecord] {
        let parser = XMLParser(contentsOf: url)
        let delegate = RouteBusXMLParserDelegate()

        parser?.delegate = delegate

        guard let parser else {
            throw RouteBusXMLReaderError.unableToCreateParser
        }

        guard parser.parse() else {
            throw parser.parserError ?? RouteBusXMLReaderError.parsingFailed
        }

        return delegate.records
    }
}

enum RouteBusXMLReaderError: Error {
    case unableToCreateParser
    case parsingFailed
}

private final class RouteBusXMLParserDelegate: NSObject, XMLParserDelegate {

    private(set) var records: [RouteBusRecord] = []

    private var currentElement = ""
    private var currentValue = ""

    private var routeID = ""
    private var companyCode = ""
    private var number = ""
    private var serviceMode = ""

    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String: String] = [:]
    ) {
        currentElement = elementName
        currentValue = ""

        if elementName == "ROUTE" {
            routeID = ""
            companyCode = ""
            number = ""
            serviceMode = ""
        }
    }

    func parser(
        _ parser: XMLParser,
        foundCharacters string: String
    ) {
        currentValue += string
    }

    func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?
    ) {
        let value = currentValue.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        switch elementName {
        case "ROUTE_ID":
            routeID = value

        case "COMPANY_CODE":
            companyCode = value

        case "ROUTE_NAMEE":
            number = value

        case "SERVICE_MODE":
            serviceMode = value

        case "ROUTE":
            records.append(
                RouteBusRecord(
                    routeID: routeID,
                    companyCode: companyCode,
                    number: number,
                    serviceMode: serviceMode
                )
            )

        default:
            break
        }

        currentElement = ""
        currentValue = ""
    }
}
