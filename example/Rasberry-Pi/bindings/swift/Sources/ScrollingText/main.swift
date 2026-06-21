import RGBLedMatrix

#if canImport(Glibc)
import Glibc
#elseif canImport(Musl)
import Musl
#endif

// Scrolling text demo: shows Font rendering + tear-free double buffering.
//
// Run on a 64-bit Raspberry Pi, as root (GPIO):
//   sudo .build/debug/ScrollingText "Your message here"
//   sudo .build/debug/ScrollingText "こんにちは" ../../fonts/10x20.bdf
//
// Args (both optional):
//   1: message text (UTF-8)
//   2: path to a BDF font (default: ../../fonts/7x13.bdf)
//
// Stop with Ctrl-C.

let message = CommandLine.arguments.count > 1
    ? CommandLine.arguments[1]
    : "Hello from Swift!   "
let fontPath = CommandLine.arguments.count > 2
    ? CommandLine.arguments[2]
    : "../../fonts/7x13.bdf"

guard let font = Font(path: fontPath) else {
    fputs("Could not load font: \(fontPath)\n", stderr)
    exit(1)
}

var options = MatrixOptions()
options.rows = 32
options.cols = 64          // single 64x32 panel
options.brightness = 70

var runtime = RuntimeOptions()
runtime.gpioSlowdown = 1   // bump to 2-4 if output is unstable

guard let matrix = LEDMatrix(options: options, runtime: runtime) else {
    fputs("Failed to create LEDMatrix.\n", stderr)
    fputs("Needs a 64-bit Raspberry Pi with the panel wired, run as root.\n", stderr)
    exit(1)
}

let (width, height) = matrix.canvas.size

// Total pixel width of the message, so we know when it has fully scrolled off.
let textWidth = message.unicodeScalars.reduce(0) { $0 + font.characterWidth($1.value) }

// Baseline y that roughly vertically centers the text.
let baselineY = (height + font.height) / 2 - 1
let textColor = Color(red: 0, green: 200, blue: 255)
let background = Color.black

// Animate on an off-screen canvas, swapping on vsync for tear-free motion.
var back = matrix.makeOffscreenCanvas()
var x = width
while true {
    back.fill(background)
    back.drawText(message, font: font, x: x, y: baselineY, color: textColor)
    back = matrix.swapOnVSync(back)
    usleep(30_000)                  // ~33 fps
    x -= 1
    if x < -textWidth { x = width } // wrap around for a continuous loop
}
