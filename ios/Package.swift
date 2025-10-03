// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PolicyLogs",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "PolicyLogs",
            targets: ["PolicyLogs"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.0"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.0.0"),
    ],
    targets: [
        .target(
            name: "PolicyLogs",
            dependencies: [
                "Alamofire",
                "Kingfisher"
            ]),
        .testTarget(
            name: "PolicyLogsTests",
            dependencies: ["PolicyLogs"]),
    ]
)