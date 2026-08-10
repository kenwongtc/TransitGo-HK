# TransitGo Architecture Notebook

Version: 0.1
Date: 2026-07-30

---

# Project Vision

TransitGo is a Hong Kong public transport application.

Goals:

- Support multiple operators:
  - KMB
  - CTB
  - NLB
  - GMB
  - MTR

- Support languages:
  - English
  - Traditional Chinese
  - Simplified Chinese

- Provide a clean user experience without excessive advertising.

- Use GitHub as the data distribution interface.

---

# System Overview

The system has two major parts:

## 1. TransitGo-Data

Purpose:

Prepare and maintain transport data.

Flow:

Government Data Sources

↓

TransitGo-Data Builder

↓

JSON Data Files

↓

GitHub Repository


## 2. TransitGo App

Purpose:

Display transport information.

Flow:

GitHub JSON Data

↓

Swift Models

↓

SwiftUI Interface

---

# Current Data Model

Operator

Route

Journey

JourneyStop

Stop

---

# Architecture Decisions

## Decision 1: Separate Operator from Route

Reason:

An operator can have many routes.

Example:

KMB

- Route 1
- Route 2
- Route 5

Therefore operator information should not be duplicated inside every route.

---

## Decision 2: Route supports multiple operators

Model:

operatorIds: [String]

Reason:

Some Hong Kong routes are jointly operated.

Example:

B1:

- KMB
- CTB

---

## Decision 3: Stop is an independent physical location

A stop exists independently from routes.

Example:

A single stop can be used by many routes.

---

## Decision 4: Use Journey between Route and Stop

Model:

Operator

↓

Route

↓

Journey

↓

JourneyStop

↓

Stop

Reason:

A route can have multiple operational versions:

- Outbound
- Inbound
- Sunday service
- Special services

---

## Decision 5: Search results show Journey destination

Example:

Instead of:

Route 1

then choose direction


Display:

Route 1 → Star Ferry

Route 1 → Chuk Yuen Estate


Reason:

More informative and reduces user actions.

---


## Decision 6: Separate Route, Journey, and Stop

Route represents the public service identity.

Journey represents an operational version of a route:
- direction
- service period
- special operation

Stop represents a physical location.

A route change should normally affect Journey/JourneyStop,
not the Stop itself.

## Decision 7: Destination belongs to Journey

A journey destination is an operational concept.

It is not necessarily the final stop of the complete route.

Examples:
- Short workings
- Special services
- Partial route operation

Therefore destination is stored in Journey.

## Decision 8: Do not rely on a circular flag from source data

Journey direction should be derived from stop relationships.

If the first and last stop are identical,
the journey may be treated as circular.

Reason:
Source transport data may not explicitly provide circular route information.

## Decision 9: Service variations are represented as Journeys

Different operating patterns are separate Journeys.

Examples:
- Weekday service
- Weekend service
- Holiday service
- Short workings

Reason:
Each service pattern may have different stops, destinations, or rules.

## Decision 10: Separate Journey from Schedule

Journey describes the operational path:
- origin
- destination
- stops
- service pattern

Schedule describes timing:
- departure times
- operating periods

Changing departure times should not create a new Journey.

## Decision 11: Circular journey display

Circular services should display both destination and circular indication.

Example:

Route 39A → A (Circular)

Reason:
Destination remains important information,
while circular status helps users understand the service pattern.


## Decision 12: Route is an identity, not an operation

Route represents the public service identity.

It contains:
- route number
- operator relationship

It does not contain:
- destination
- direction
- stop sequence
- timetable

Reason:
The same route can have multiple journeys with different operational details.

## Decision 13: Stop sequence belongs to JourneyStop

A Stop is a physical location.

A Journey defines an operational path.

JourneyStop connects them and stores the sequence.

Reason:
The same Stop can appear at different positions on different journeys.

## Decision 14: Separate JSON entities

TransitGo GitHub data will separate:

- operators.json
- routes.json
- journeys.json
- journey_stops.json
- stops.json

Reason:

- Avoid duplicate data
- Easier maintenance
- Easier updates
- Better scalability for multiple operators

## Decision 14: Separate JSON entities

TransitGo GitHub data will separate:

- operators.json
- routes.json
- journeys.json
- journey_stops.json
- stops.json

Reason:

- Avoid duplicate data
- Easier maintenance
- Easier updates
- Better scalability for multiple operators

## Decision 16: Data preparation belongs to TransitGo-Data

TransitGo-Data is responsible for:

- importing external sources
- cleaning data
- creating relationships
- generating stable IDs

The iPhone app is responsible for:

- UI
- user interaction
- searching
- displaying data

Reason:
The app should consume clean data, not process raw transport sources.

## Decision 17: Use simple model names

Models use domain names:

- Operator
- Route
- Journey
- JourneyStop
- Stop
- Schedule

Reason:
TransitGo context already defines the meaning.
Keep names simple and readable.

## Decision 21: Preserve reliable external IDs

When a source system provides a stable identifier,
TransitGo should preserve it.

Example:
- Stop IDs from transport data

Names are display information and may change.

## Decision 23: Use SwiftData for local storage

TransitGo will:

1. Download clean JSON from GitHub
2. Import data into SwiftData
3. Use SwiftData for app operation

Reasons:

- Faster queries
- Offline support
- Better relationship handling
- JSON does not need to be parsed repeatedly

## Decision 24: Store latest dataset only

SwiftData will contain only the current TransitGo dataset.

Update process:
- validate new data
- replace old local data
- import latest version

Reason:
Old transport information may confuse users.
TransitGo focuses on current passenger information.

## Decision 25: Version-based data updates

TransitGo checks dataset version.

Rules:
- Same version → use local SwiftData
- New version → download and replace
- User can manually trigger update

Reason:
Reduce unnecessary downloads while keeping data current.

## Decision 26: Separate JSON files

TransitGo GitHub data is separated by entity.

Files:
- operators.json
- routes.json
- journeys.json
- journey_stops.json
- stops.json
- schedules.json

Reasons:
- smaller downloads
- easier maintenance
- clearer ownership
- easier future expansion

## Decision 27: Support all operators from the beginning

Initial TransitGo operator model includes:

- KMB
- CTB
- NLB
- GMB
- MTR

Reason:
The architecture must support:
- joint operations
- multiple transport operators
- future expansion

## Decision 28: JSON collection files use arrays

Each JSON file stores a list of entities.

Example:

operators.json
[
    Operator,
    Operator,
    Operator
]

Reason:
Model represents one item.
JSON file represents a collection.
