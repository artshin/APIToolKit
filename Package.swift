// swift-tools-version: 5.6

import PackageDescription

let package = Package(
  name: "APIToolkit",
  platforms: [.macOS(.v10_15), .iOS(.v13)],
  products: [
    .library(
      name: "APIToolKit",
      targets: ["APIToolKit"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/objecthub/swift-commandlinekit.git", exact: "0.3.4")
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    .target(
      name: "APIToolKit",
      dependencies: []
    ),
    .testTarget(
      name: "APIToolKitTests",
      dependencies: ["APIToolKit"]
    ),
    .executableTarget(
      name: "CLI",
      dependencies: [
        "APIToolKit",
        .product(name: "CommandLineKit", package: "swift-commandlinekit")
      ]
    )
  ]
)
