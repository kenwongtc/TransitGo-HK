// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TransitGo-HK",

    platforms: [
        .macOS(.v12)
    ],
    
    targets: [

        .executableTarget(
            name: "TransitGo-HK-Data",
            resources: [
                .process("Resources")
            ]
        ),

        .testTarget(
            name: "TransitGo-HK-DataTests",
            dependencies: [
                "TransitGo-HK-Data"
            ]
        )
    ],

    swiftLanguageModes: [.v6]
)
