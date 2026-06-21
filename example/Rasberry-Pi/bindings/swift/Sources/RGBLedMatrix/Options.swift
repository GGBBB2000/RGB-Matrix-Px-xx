/// Matrix configuration. Mirrors the most common fields of the C
/// `struct RGBLedMatrixOptions`. A field left at 0 / nil means "use the
/// library default" (the C bridge only applies non-zero values).
public struct MatrixOptions {
    public var rows: Int = 32
    public var cols: Int = 32
    public var chainLength: Int = 1
    public var parallel: Int = 1
    /// PWM bits (0 = library default, typically 11).
    public var pwmBits: Int = 0
    /// Panel brightness 1...100 (0 = library default).
    public var brightness: Int = 0
    public var hardwareMapping: String? = nil
    public var ledRgbSequence: String? = nil
    public var pixelMapperConfig: String? = nil
    public var panelType: String? = nil
    public var showRefreshRate: Bool = false
    public var disableHardwarePulsing: Bool = false
    public var inverseColors: Bool = false

    public init() {}
}

/// Runtime options.
///
/// Note: the underlying C bridge only forwards *non-zero* runtime values, so
/// only knobs whose meaningful values are non-zero can be set this way. The
/// most useful one — GPIO slowdown — is exposed here. `do_gpio_init` is always
/// enabled (the C bridge cannot disable it), so creating a matrix requires a
/// real Pi with GPIO access.
public struct RuntimeOptions {
    /// Slow down GPIO toggling for faster Pis / fussy panels (1...4).
    public var gpioSlowdown: Int = 1

    public init() {}
}
