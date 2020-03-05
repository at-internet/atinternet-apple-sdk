// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "ATInternetTracker",
  platforms: [
      .macOS(.v10_15),
      .iOS(.v13),
      .watchOS(.v6),
      .tvOS(.v13)//,
      // this should works on linux too ;) (because of swift-crypto)
  ],
  products: [
    .library(name: "ATInternetTracker", type: .static, targets: ["ATInternetTracker"]),
    .library(name: "ATInternetTrackerDynamic", type: .dynamic, targets: ["ATInternetTracker"]) //,
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-crypto.git", from: "1.0.0"),
  ],
  targets: [
    .target(
      name: "ATInternetTracker",
      dependencies: ["Crypto"],
      path: "ATInternetTracker/Sources",
      exclude: [
        "Crash.h",
        "Crash.m",
        "Hash.h",
        "Hash.m"
      ] //,
//      swiftSettings : [
//        SwiftSetting.define("ENABLE_CRASH_REPORTER"),
//        SwiftSetting.define("ENABLE_HASH")
//      ]
    ),
    .testTarget(
      name: "ATInternetTrackerTest",
      dependencies: ["ATInternetTracker"],
      path: "ATInternetTracker/Tests",
      exclude: []
    )
  ],
  swiftLanguageVersions: [.v5]
)
