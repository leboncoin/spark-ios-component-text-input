// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// swiftlint:disable all
let package = Package(
    name: "SparkTextInput",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "SparkTextInput",
            targets: ["SparkTextInput"]
        ),
        .library(
            name: "SparkTextInputTesting",
            targets: ["SparkTextInputTesting"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/adevinta/spark-ios-common.git",
            branch: "snapshots"
        ),
//       .package(
//           url: "https://github.com/adevinta/spark-ios-common.git",
//           // path: "../spark-ios-common"
//           /*version*/ "0.0.1"..."999.999.999"
//       ),
       .package(
           url: "https://github.com/adevinta/spark-ios-theming.git",
           // path: "../spark-ios-theming"
           /*version*/ "0.0.1"..."999.999.999"
       )
    ],
    targets: [
        .target(
            name: "SparkTextInput",
            dependencies: [
                .product(
                    name: "SparkCommon",
                    package: "spark-ios-common"
                ),
                .product(
                    name: "SparkTheming",
                    package: "spark-ios-theming"
                )
            ],
            path: "Sources/Core"
        ),
        .target(
            name: "SparkTextInputTesting",
            dependencies: [
                "SparkTextInput",
                .product(
                    name: "SparkCommon",
                    package: "spark-ios-common"
                ),
                .product(
                    name: "SparkCommonTesting",
                    package: "spark-ios-common"
                ),
                .product(
                    name: "SparkThemingTesting",
                    package: "spark-ios-theming"
                ),
                .product(
                    name: "SparkTheme",
                    package: "spark-ios-theming"
                )
            ],
            path: "Sources/Testing"
        ),
        .testTarget(
            name: "SparkTextInputUnitTests",
            dependencies: [
                "SparkTextInput",
                "SparkTextInputTesting",
                .product(
                    name: "SparkCommonTesting",
                    package: "spark-ios-common"
                ),
                .product(
                    name: "SparkThemingTesting",
                    package: "spark-ios-theming"
                )
            ],
            path: "Tests/UnitTests"
        ),
        .testTarget(
            name: "SparkTextInputSnapshotTests",
            dependencies: [
                "SparkTextInput",
                "SparkTextInputTesting",
                .product(
                    name: "SparkCommonSnapshotTesting",
                    package: "spark-ios-common"
                ),
            ],
            path: "Tests/SnapshotTests"
        ),
    ]
)
