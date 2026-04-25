// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BillionCalcCore",
    platforms: [
        .iOS(.v17),
        .macOS(.v13)
    ],
    products: [
        .library(name: "BillionCalcCore", targets: ["BillionCalcCore"]),
        .executable(name: "BillionCalcVerify", targets: ["BillionCalcVerify"])
    ],
    targets: [
        .target(name: "BillionCalcCore", path: "Sources/BillionCalcCore"),
        .executableTarget(
            name: "BillionCalcVerify",
            dependencies: ["BillionCalcCore"],
            path: "Sources/BillionCalcVerify"
        ),
        .testTarget(
            name: "BillionCalcCoreTests",
            dependencies: ["BillionCalcCore"],
            path: "Tests/BillionCalcCoreTests"
        )
    ]
)
