// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ATInternet",
    platforms: [.iOS(.v10), .tvOS(.v10), .watchOS(.v3)],
    products: [
        .library(name: "Tracker", targets: ["Tracker"]),
        .library(name: "TrackerExtension", targets: ["TrackerExtension"]),
    ],
    targets: [
        .target(
            name: "Tracker",
            dependencies: ["TrackerObjc"],
            path: "ATInternetTracker/Sources",
            exclude: [
                "Hash.m",
                "Crash.m",
                "Info-iOS.plist",
                "Info-iOS-Extension.plist",
                "Info-tvOS.plist",
                "Info-watchOS.plist",
                "referential.json",
                "Tracker.h",
                "TrackerExtension.h",
                "TrackerTests-Bridging-Header.h",
                "tvOSTracker.h",
                "watchOSTracker.h",
            ],
            resources: [
                .copy("TrackerBundle.bundle"),
                .copy("DefaultConfiguration.plist"),
                .copy("DefaultConfiguration~ipad.plist"),
                .copy("DefaultConfiguration~iphone.plist"),
                .copy("DefaultConfiguration~ipod.plist"),
            ]),
        .target(
            name: "TrackerExtension",
            dependencies: ["TrackerObjc"],
            path: "ATInternetTracker/AppExtension",
            exclude: [
                "Hash.m",
                "Crash.m",
                "Info-iOS.plist",
                "Info-iOS-Extension.plist",
                "Info-tvOS.plist",
                "Info-watchOS.plist",
                "referential.json",
                "BackgroundTask.swift",
                "Debugger.swift",
                "Tracker.h",
                "TrackerExtension.h",
                "TrackerTests-Bridging-Header.h",
                "tvOSTracker.h",
                "watchOSTracker.h",
            ],
            resources: [
                .copy("TrackerBundle.bundle"),
                .copy("DefaultConfiguration.plist"),
                .copy("DefaultConfiguration~ipad.plist"),
                .copy("DefaultConfiguration~iphone.plist"),
                .copy("DefaultConfiguration~ipod.plist"),
            ],
            swiftSettings: [.define("AT_EXTENSION")]),
        .target(
            name: "TrackerObjc",
            path: "ATInternetTracker/Objc"),
    ]
)

