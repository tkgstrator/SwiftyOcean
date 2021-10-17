// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SeedHack",
    platforms:  [
        .iOS(.v14), .macOS(.v10_15)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SeedHack",
            targets: ["SeedHack"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "Benchmark", url: "https://github.com/tkgstrator/swift-benchmark", from: "0.1.2"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SeedHack",
            dependencies: ["Benchmark"]),
        .testTarget(
            name: "SeedHackTests",
            dependencies: ["SeedHack", "Benchmark"]),
    ]
)
