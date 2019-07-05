// swift-tools-version:5.0

import PackageDescription

let package = Package(
  name: "AudioPlayer",
  platforms: [
    .macOS(.v10_12),
    .iOS(.v12),
    .tvOS(.v12)
  ],
  products: [
    .library(name: "AudioPlayer", targets: ["AudioPlayer"])
  ],
  dependencies: [
    .package(path: "../MediaApis")
  ],
  targets: [
    .target(
      name: "AudioPlayer",
      dependencies: [
        "MediaApis"
      ]),
    .testTarget(
      name: "AudioPlayerTests",
      dependencies: [
        "AudioPlayer"
      ])
  ]
)
