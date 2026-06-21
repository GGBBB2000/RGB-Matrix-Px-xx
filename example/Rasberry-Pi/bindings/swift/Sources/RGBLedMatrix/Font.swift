import CRGBMatrix

/// A BDF bitmap font, loaded from a `.bdf` file (see the `fonts/` directory).
public final class Font {
    let handle: OpaquePointer

    public init?(path: String) {
        guard let h = load_font(path) else { return nil }
        self.handle = h
    }

    deinit { delete_font(handle) }

    public var height: Int { Int(height_font(handle)) }
    public var baseline: Int { Int(baseline_font(handle)) }

    public func characterWidth(_ codepoint: UInt32) -> Int {
        Int(character_width_font(handle, codepoint))
    }
}

// Text and primitive drawing live as Canvas extensions so they read naturally.
extension Canvas {
    /// Draw UTF-8 text; returns how many pixels wide the text was.
    @discardableResult
    public func drawText(_ text: String, font: Font, x: Int, y: Int,
                         color: Color, kerning: Int = 0) -> Int {
        Int(draw_text(handle, font.handle, Int32(x), Int32(y),
                      color.red, color.green, color.blue, text, Int32(kerning)))
    }

    public func drawLine(fromX x0: Int, fromY y0: Int, toX x1: Int, toY y1: Int,
                         color: Color) {
        draw_line(handle, Int32(x0), Int32(y0), Int32(x1), Int32(y1),
                  color.red, color.green, color.blue)
    }

    public func drawCircle(centerX: Int, centerY: Int, radius: Int, color: Color) {
        draw_circle(handle, Int32(centerX), Int32(centerY), Int32(radius),
                    color.red, color.green, color.blue)
    }
}
