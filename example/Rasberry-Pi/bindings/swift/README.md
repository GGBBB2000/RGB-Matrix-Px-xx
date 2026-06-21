Swift bindings for the RGB Matrix library
=========================================

A thin Swift wrapper over the library's flat C API (`include/led-matrix-c.h`).
Swift imports the C header directly as a module, so there are no hand-written
function declarations to keep in sync (unlike the C# P/Invoke layer).

Platform requirements
---------------------

**Swift's official toolchain is 64-bit only (x86_64 / aarch64 Linux).**
There is **no Swift for 32-bit ARM (ARMv6/armv7)**, so this binding **cannot run
on the original Pi Zero / Pi 1**. To drive a panel from Swift you need a 64-bit
Pi running a 64-bit (aarch64) OS:

- Raspberry Pi Zero 2 W (with 64-bit Raspberry Pi OS)
- Raspberry Pi 3 / 4 / 5

On such boards the core library builds with a plain `make` (the ARMv6 build
workarounds are not needed on aarch64).

Layout
------

- `Sources/CRGBMatrix` – thin C-import module (modulemap + umbrella header that
  re-includes `../../include/led-matrix-c.h`).
- `Sources/RGBLedMatrix` – ergonomic Swift wrapper: `LEDMatrix`, `Canvas`,
  `Color`, `MatrixOptions`, `RuntimeOptions`, `Font`, plus `RGBMatrixDiagnostics`.
- `Sources/SmokeTest` – hardware-free verification (no GPIO/root/panel).
- `Sources/MinimalExample` – real example that drives a 64x32 panel.

Build
-----

1. Build the core library **without LTO** (produces `../../lib/librgbmatrix.a`).
   This is required: the static archive is linked by Swift's LLVM-based linker,
   which cannot read GCC's LTO bytecode objects. Disable LTO with `LTO_FLAGS=`:

   ```
   make -C ../lib clean
   make -C ../lib LTO_FLAGS=
   ```

   On a 64-bit Pi that is all you need. (The C# binding sidesteps this by linking
   the fully-built `.so`; here we link the `.a` statically to avoid runtime
   library-path setup.)

2. Build the Swift package:

   ```
   cd bindings/swift
   swift build
   ```

Run
---

Hardware-free smoke test (works on any 64-bit Linux, including your dev box):

```
swift run SmokeTest
```

Real panel output (64-bit Pi only, needs root for GPIO):

```
sudo .build/debug/MinimalExample
# or: sudo swift run MinimalExample
```

Usage sketch
------------

```swift
import RGBLedMatrix

var options = MatrixOptions()
options.rows = 32
options.cols = 64

guard let matrix = LEDMatrix(options: options) else { fatalError("need a Pi + GPIO") }

let canvas = matrix.canvas
canvas.fill(.black)
canvas.setPixel(x: 0, y: 0, color: .red)

// double-buffered animation
var back = matrix.makeOffscreenCanvas()
back.fill(.blue)
back = matrix.swapOnVSync(back)
```

Notes / limitations
-------------------

- The C bridge (`led-matrix-c.cc`) only forwards *non-zero* option values, so a
  field left at 0 / nil means "library default". It also cannot disable GPIO
  init, which is why creating an `LEDMatrix` always requires real hardware.
- `Canvas` is a non-owning handle; its lifetime is tied to the owning `LEDMatrix`.
- Run as root: GPIO access requires it.
