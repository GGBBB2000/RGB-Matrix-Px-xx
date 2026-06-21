import CRGBMatrix

/// A drawable surface. Non-owning handle: the owning `LEDMatrix` manages its
/// lifetime, so `Canvas` is a lightweight value type.
public struct Canvas {
    let handle: OpaquePointer
    init(_ handle: OpaquePointer) { self.handle = handle }

    /// Pixel dimensions of the canvas.
    public var size: (width: Int, height: Int) {
        var w: Int32 = 0
        var h: Int32 = 0
        led_canvas_get_size(handle, &w, &h)
        return (Int(w), Int(h))
    }

    public func setPixel(x: Int, y: Int, color: Color) {
        led_canvas_set_pixel(handle, Int32(x), Int32(y), color.red, color.green, color.blue)
    }

    public func fill(_ color: Color) {
        led_canvas_fill(handle, color.red, color.green, color.blue)
    }

    public func fill(x: Int, y: Int, width: Int, height: Int, color: Color) {
        led_canvas_subfill(handle, Int32(x), Int32(y), Int32(width), Int32(height),
                           color.red, color.green, color.blue)
    }

    public func clear() {
        led_canvas_clear(handle)
    }
}
