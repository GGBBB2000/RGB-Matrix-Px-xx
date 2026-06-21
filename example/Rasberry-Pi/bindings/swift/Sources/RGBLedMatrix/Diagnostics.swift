import CRGBMatrix

#if canImport(Glibc)
import Glibc
#elseif canImport(Musl)
import Musl
#endif

/// Hardware-free helpers, useful for verifying the binding without a panel.
public enum RGBMatrixDiagnostics {
    /// Print the library's available command-line flags to stderr. This makes a
    /// real call into the C++ core and needs no GPIO, so it doubles as a
    /// runtime linkage check.
    public static func printAvailableFlags() {
        led_matrix_print_flags(stderr)
    }
}
