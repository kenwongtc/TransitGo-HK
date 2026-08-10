# TransitGo-HK — Phase 3 Handover

**Date:** 2026-08-10

## Project

* Swift 6
* Swift Package: `TransitGo-HK`
* Executable target: `TransitGo-HK-Data`
* Test target: `TransitGo-HK-DataTests`
* Project root:

```text
/Users/ken/Projects/TransitGo-HK (ChatGPT)/TransitGo-HK-Data
```

## Project Rules

* Keep responses short.
* For every created/modified file, show the full absolute path.
* Ask only important architecture questions.
* No automatic documentation.
* No Git comments.
* Build/test after every meaningful step.
* Do not recreate completed Phase 1 work.

## Architecture

```text
Readers
   ↓
Validators
   ↓
Builders
   ↓
MasterData
   ↓
MasterDataValidator
   ↓
MasterDataExporter
   ↓
JSON
   ↓
Future SwiftData
```

JSON is the intermediate dataset.

SwiftData will eventually be used as the offline store.

## Core Models

```text
Operator
Route
Journey
JourneyStop
Stop
Schedule
```

## Real Data Sources

```text
COMPANY_CODE.xml
ROUTE_BUS.xml
RSTOP_BUS.xml
STOP_BUS.xml
```

Mapping:

```text
COMPANY_CODE.xml → Operator
ROUTE_BUS.xml    → Route
RSTOP_BUS.xml    → Journey
RSTOP_BUS.xml    → JourneyStop
STOP_BUS.xml     → Stop
```

## Verified Real Data

Current real-data counts:

```text
Operators       = 14
Routes          = 1,609
Journeys        = 2,356
Stops           = 4,480
JourneyStops    = real records
Schedules       = 0
```

`Schedule` is currently empty.

We decided **not** to force ETA or real-time data into `Schedule`.

The four static XML files do not contain timetable departure times.

ETA should eventually be a separate real-time model/layer.

## Journey Mapping

Journey ID:

```text
ROUTE_ID + "-" + ROUTE_SEQ
```

Example:

```text
1000001-1
1000001-2
```

Fields:

```text
journeyId
routeId
originStopId
destinationStopId
direction
serviceType
```

`serviceType` comes from `SERVICE_MODE`.

Origin and destination are derived from the first/last stop in the corresponding `RSTOP_BUS.xml` route/direction records.

## JourneyStop Mapping

```text
journeyId = ROUTE_ID + "-" + ROUTE_SEQ
stopId    = STOP_ID
sequence  = STOP_SEQ
```

The source ordering is preserved.

## Important Fixes Already Completed

### 1. Swift 6 Dictionary issue

This caused:

```text
type '(String, Int)' cannot conform to 'Hashable'
```

The grouping key was changed from:

```swift
($0.routeID, $0.routeSequence)
```

to a String key such as:

```swift
"\($0.routeID)|\($0.routeSequence)"
```

### 2. SERVICE_MODE

`RouteBusXMLReader` was updated to capture:

```text
SERVICE_MODE
```

This is now used by `RealJourneyBuilder`.

### 3. RealStopBuilder

A string interpolation syntax error was corrected.

### 4. RealJourneyBuilder

Real journeys are now successfully generated.

Example output:

```text
Journey: 1000001-1 route: 1000001 origin: 9571 destination: 13183 direction: 1 serviceType: T
Journey: 1000001-2 route: 1000001 origin: 9577 destination: 9578 direction: 2 serviceType: T
Journey: 1000002-1 route: 1000002 origin: 13183 destination: 13387 direction: 1 serviceType: T
```

## Real Builders

These have been created and tested:

```text
RealOperatorBuilder.swift
RealRouteBuilder.swift
RealJourneyBuilder.swift
RealJourneyStopBuilder.swift
RealStopBuilder.swift
RealDataBuilder.swift
```

Existing readers include:

```text
CompanyCodeReader.swift
RouteBusXMLReader.swift
RStopBusXMLReader.swift
StopBusXMLReader.swift
```

## MasterData

Current model:

```swift
struct MasterData: Codable {

    let operators: [Operator]
    let routes: [Route]
    let journeys: [Journey]
    let journeyStops: [JourneyStop]
    let stops: [Stop]
    let schedules: [Schedule]
}
```

## Existing DataBuilder

There is an existing:

```text
DataBuilder
```

It uses the JSON-based builders:

```text
OperatorBuilder
RouteBuilder
JourneyBuilder
JourneyStopBuilder
StopBuilder
ScheduleBuilder
```

**Do not replace it blindly.**

The new real-data pipeline is intentionally separate:

```text
RealDataBuilder
```

## RealDataBuilder

Current design:

```text
RealOperatorBuilder
        ↓
RealRouteBuilder
        ↓
RealJourneyBuilder
        ↓
RealJourneyStopBuilder
        ↓
RealStopBuilder
        ↓
MasterData
        ↓
MasterDataValidator
```

Schedules currently use:

```swift
schedules: []
```

## MasterDataExporter

Existing exporter already works.

It exports:

```text
operators.json
routes.json
journeys.json
journeyStops.json
stops.json
schedules.json
```

The exporter did not need modification.

## Tests Verified

These tests have passed:

```text
RealRouteBuilderTests
RealJourneyBuilderTests
RealJourneyStopBuilderTests
RealMasterDataTests
RealDataBuilderTests
RealMasterDataExporterTests
```

Also previously verified:

```text
DataVersionManagerTests
MasterDataExporterTests
CompanyCode real-data test
BusXMLReaderTests
BusXMLRelationshipTests
HKGridConverterTests
```

The major relationship test previously had 760 failures but was fixed and now passes.

## Latest Test Results

### RealDataBuilderTests

```text
Executed 1 test, with 0 failures
```

### RealMasterDataExporterTests

```text
Executed 1 test, with 0 failures
```

## Final Executable Integration

The executable entry point is:

```text
Sources/TransitGo-HK-Data/TransitGo-HK-Data.swift
```

It was changed to:

```swift
import Foundation

@main
struct TransitGo_Data {

    static func main() {

        print("""
        ===========================
        TransitGo-HK Data Generator
        ===========================
        """)

        do {
            let masterData = try RealDataBuilder().build()

            let outputDirectory = URL(
                fileURLWithPath: FileManager.default.currentDirectoryPath
            )
            .appendingPathComponent("Output")

            try MasterDataExporter().export(
                masterData,
                to: outputDirectory
            )

            print("Export completed.")
            print("Output: \(outputDirectory.path)")
            print("Operators: \(masterData.operators.count)")
            print("Routes: \(masterData.routes.count)")
            print("Journeys: \(masterData.journeys.count)")
            print("JourneyStops: \(masterData.journeyStops.count)")
            print("Stops: \(masterData.stops.count)")
            print("Schedules: \(masterData.schedules.count)")

        } catch {
            print("ERROR: \(error)")
        }
    }
}
```

### IMPORTANT

This final executable change has **NOT yet been run and verified**.

## Immediate Next Step

Run:

```bash
swift build
swift run
```

Expected output should show approximately:

```text
Export completed.
Operators: 14
Routes: 1609
Journeys: 2356
JourneyStops: ...
Stops: 4480
Schedules: 0
```

And create:

```text
Output/
├── operators.json
├── routes.json
├── journeys.json
├── journeyStops.json
├── stops.json
└── schedules.json
```

## After That

1. Verify the generated JSON.
2. Verify the counts.
3. Verify the exported data can be read back.
4. Decide where the generated JSON should be committed/hosted.
5. Later investigate timetable sources.
6. Later add ETA as a separate real-time layer.
7. Later integrate SwiftData for offline storage.

## Schedule Decision

Do **not** implement Schedule using ETA.

```text
Schedule = planned timetable
ETA      = real-time prediction
```

They are different concepts.

The current four XML files do not provide the timetable needed for `Schedule`.

## New Account Continuation Message

Paste this after uploading the project files:

> Continue **TransitGo-HK** from this handover.
>
> Swift 6.
>
> Package:
>
> `TransitGo-HK`
>
> Executable target:
>
> `TransitGo-HK-Data`
>
> Test target:
>
> `TransitGo-HK-DataTests`
>
> Please read `PHASE_3_HANDOVER.md` first.
>
> Do not recreate completed Phase 1 or Phase 2 work.
>
> The real static XML pipeline is working:
>
> `COMPANY_CODE.xml → Operator`
>
> `ROUTE_BUS.xml → Route`
>
> `RSTOP_BUS.xml → Journey / JourneyStop`
>
> `STOP_BUS.xml → Stop`
>
> Verified counts:
>
> * 14 operators
> * 1,609 routes
> * 2,356 journeys
> * 4,480 stops
>
> `RealDataBuilderTests` and `RealMasterDataExporterTests` pass.
>
> The last unfinished step is running and verifying the executable after connecting `RealDataBuilder` to `MasterDataExporter`.
>
> Start with:
>
> ```bash
> swift build
> swift run
> ```
>
> Keep responses short.
>
> For every changed file, show the full absolute path.

