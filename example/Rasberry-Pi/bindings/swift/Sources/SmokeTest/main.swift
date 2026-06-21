import RGBLedMatrix

// Hardware-free verification of the Swift <-> C binding.
// Runs on any 64-bit Linux (x86_64 or aarch64) -- no GPIO, no root, no panel.
// It exercises: dynamic linkage against the C++ core, calling convention,
// opaque-pointer handling, String passing, return values, and RAII deinit.

print("== RGB Matrix Swift binding smoke test ==")

// [1] Call into the C++ core at runtime (no GPIO needed).
print("\n[1] led_matrix_print_flags -> (printed to stderr below):")
RGBMatrixDiagnostics.printAvailableFlags()

// [2] Exercise a non-GPIO C API path through the wrapper: load a bundled font.
//     Path is relative to the package dir; run via `swift run` from here.
let fontPath = "../../fonts/7x13.bdf"
if let font = Font(path: fontPath) {
    let aWidth = font.characterWidth(UInt32(UnicodeScalar("A").value))
    print("\n[2] Loaded \(fontPath): height=\(font.height) baseline=\(font.baseline) width('A')=\(aWidth)")
} else {
    print("\n[2] Could not load \(fontPath) (run from bindings/swift, with the core fonts present).")
}

// [3] Value-type wrapper sanity.
let c = Color.red
print("\n[3] Color.red = (\(c.red), \(c.green), \(c.blue))")

print("\n== Smoke test complete: Swift <-> C linkage verified. ==")
print("Creating an actual LEDMatrix needs real GPIO (a 64-bit Pi, run as root).")
print("See MinimalExample for that.")
