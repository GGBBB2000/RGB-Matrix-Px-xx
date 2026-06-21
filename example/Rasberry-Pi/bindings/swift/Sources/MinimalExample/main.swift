import RGBLedMatrix

#if canImport(Glibc)
import Glibc
#elseif canImport(Musl)
import Musl
#endif

// Minimal real example: fill the panel, draw a diagonal, animate via double
// buffering. Requires a 64-bit Raspberry Pi with the HUB75 panel wired and
// must be run as root (GPIO). On non-Pi hosts, matrix creation returns nil.

var options = MatrixOptions()
options.rows = 32
options.cols = 64        // a single 64x32 panel

var runtime = RuntimeOptions()
runtime.gpioSlowdown = 1 // bump to 2-4 if the output is unstable

guard let matrix = LEDMatrix(options: options, runtime: runtime) else {
    fputs("Failed to create LEDMatrix.\n", stderr)
    fputs("Expected unless you're on a Raspberry Pi with GPIO, running as root.\n", stderr)
    exit(1)
}

let (w, h) = matrix.canvas.size
print("Matrix created: \(w)x\(h)")

// Static frame on the visible canvas.
let canvas = matrix.canvas
canvas.fill(Color(red: 0, green: 40, blue: 0))
for i in 0..<min(w, h) {
    canvas.setPixel(x: i, y: i, color: .white)
}
sleep(2)

// Double-buffered animation: a moving vertical bar.
var back = matrix.makeOffscreenCanvas()
for frame in 0..<(w * 2) {
    back.clear()
    let x = frame % w
    back.fill(x: x, y: 0, width: 1, height: h, color: .blue)
    back = matrix.swapOnVSync(back)
    usleep(40_000)
}

matrix.canvas.clear()
print("Done.")
