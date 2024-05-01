// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ACBAVPlayerExtension",
	platforms: [
		.iOS(.v10),
		.macOS(.v10_12)
	],
    products: [
        .library(
            name: "ACBAVPlayerExtension",
            targets: ["ACBAVPlayerExtension"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "ACBAVPlayerExtension",
            path: "ACBAVPlayerExtension/Classes/AudioProcessing",
            dependencies: []),
    ],
    swiftLanguageVersions: [.v5]
)
