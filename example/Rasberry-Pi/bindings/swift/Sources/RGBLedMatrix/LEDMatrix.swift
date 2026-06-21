import CRGBMatrix

#if canImport(Glibc)
import Glibc
#elseif canImport(Musl)
import Musl
#endif

/// Owns an RGB LED matrix and its refresh thread.
///
/// Creating an instance initializes GPIO and therefore requires running on a
/// Raspberry Pi (64-bit, for Swift) as root. On other platforms the initializer
/// returns `nil`.
public final class LEDMatrix {
    private let handle: OpaquePointer
    // The C options struct stores raw `const char *` pointers, so any strings
    // we pass must outlive the matrix. We own them here and free on deinit.
    private let ownedCStrings: [UnsafeMutablePointer<CChar>]

    public init?(options: MatrixOptions = MatrixOptions(),
                 runtime: RuntimeOptions = RuntimeOptions()) {
        var cOpts = RGBLedMatrixOptions()
        memset(&cOpts, 0, MemoryLayout<RGBLedMatrixOptions>.size)
        cOpts.rows = Int32(options.rows)
        cOpts.cols = Int32(options.cols)
        cOpts.chain_length = Int32(options.chainLength)
        cOpts.parallel = Int32(options.parallel)
        cOpts.pwm_bits = Int32(options.pwmBits)
        cOpts.brightness = Int32(options.brightness)
        cOpts.show_refresh_rate = options.showRefreshRate
        cOpts.disable_hardware_pulsing = options.disableHardwarePulsing
        cOpts.inverse_colors = options.inverseColors

        var owned: [UnsafeMutablePointer<CChar>] = []
        func dup(_ s: String?) -> UnsafePointer<CChar>? {
            guard let s = s, let p = strdup(s) else { return nil }
            owned.append(p)
            return UnsafePointer(p)
        }
        cOpts.hardware_mapping = dup(options.hardwareMapping)
        cOpts.led_rgb_sequence = dup(options.ledRgbSequence)
        cOpts.pixel_mapper_config = dup(options.pixelMapperConfig)
        cOpts.panel_type = dup(options.panelType)

        var cRt = RGBLedRuntimeOptions()
        memset(&cRt, 0, MemoryLayout<RGBLedRuntimeOptions>.size)
        cRt.gpio_slowdown = Int32(runtime.gpioSlowdown)
        cRt.do_gpio_init = true

        guard let h = led_matrix_create_from_options_and_rt_options(&cOpts, &cRt) else {
            owned.forEach { free($0) }
            return nil
        }
        self.handle = h
        self.ownedCStrings = owned
    }

    deinit {
        led_matrix_delete(handle)
        ownedCStrings.forEach { free($0) }
    }

    /// The active, on-screen canvas. Draw here for immediate (un-buffered) output.
    public var canvas: Canvas {
        Canvas(led_matrix_get_canvas(handle)!)
    }

    /// Create an off-screen canvas for double-buffered, tear-free animation.
    public func makeOffscreenCanvas() -> Canvas {
        Canvas(led_matrix_create_offscreen_canvas(handle)!)
    }

    /// Swap `canvas` onto the display at the next vsync; returns the now-inactive
    /// buffer to draw the next frame into.
    @discardableResult
    public func swapOnVSync(_ canvas: Canvas) -> Canvas {
        Canvas(led_matrix_swap_on_vsync(handle, canvas.handle)!)
    }

    public var brightness: UInt8 {
        get { led_matrix_get_brightness(handle) }
        set { led_matrix_set_brightness(handle, newValue) }
    }
}
