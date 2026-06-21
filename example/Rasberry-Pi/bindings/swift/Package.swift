// swift-tools-version:5.9
import PackageDescription
import Foundation

// The C++ core library (librgbmatrix.a) and its C header live outside this
// package, in the parent `example/Rasberry-Pi` tree. Resolve absolute paths
// from this manifest's own location so `swift build` works regardless of CWD.
let packageDir = URL(fileURLWithPath: #filePath).deletingLastPathComponent().path
let rgbLibDir = "\(packageDir)/../../lib"

// Build the core first with:  make -C ../..   (produces ../../lib/librgbmatrix.a)
let linkRGBMatrix: [LinkerSetting] = [
    .unsafeFlags([
        "-L\(rgbLibDir)",
        "-lrgbmatrix",   // the C/C++ core (static archive)
        "-lstdc++",      // core is C++
        "-lpthread",
        "-lrt",
        "-lm",
    ])
]

let package = Package(
    name: "RGBLedMatrix",
    products: [
        .library(name: "RGBLedMatrix", targets: ["RGBLedMatrix"]),
        .executable(name: "SmokeTest", targets: ["SmokeTest"]),
        .executable(name: "MinimalExample", targets: ["MinimalExample"]),
        .executable(name: "ScrollingText", targets: ["ScrollingText"]),
    ],
    targets: [
        // Thin C-import target: exposes the existing led-matrix-c.h to Swift.
        .target(name: "CRGBMatrix"),

        // Ergonomic Swift wrapper over the C API.
        .target(
            name: "RGBLedMatrix",
            dependencies: ["CRGBMatrix"]
        ),

        // Hardware-free smoke test (no GPIO): verifies Swift <-> C linkage.
        .executableTarget(
            name: "SmokeTest",
            dependencies: ["RGBLedMatrix"],
            linkerSettings: linkRGBMatrix
        ),

        // Real example: drives the panel. Needs a 64-bit Pi + GPIO + sudo.
        .executableTarget(
            name: "MinimalExample",
            dependencies: ["RGBLedMatrix"],
            linkerSettings: linkRGBMatrix
        ),

        // Scrolling text demo (Font + double buffering). 64-bit Pi + sudo.
        .executableTarget(
            name: "ScrollingText",
            dependencies: ["RGBLedMatrix"],
            linkerSettings: linkRGBMatrix
        ),
    ]
)
