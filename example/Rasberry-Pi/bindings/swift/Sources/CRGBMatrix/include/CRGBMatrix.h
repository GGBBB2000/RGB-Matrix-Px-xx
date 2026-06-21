#ifndef CRGBMATRIX_UMBRELLA_H
#define CRGBMATRIX_UMBRELLA_H

/*
 * Umbrella header for the Swift `CRGBMatrix` module.
 *
 * It simply re-includes the existing flat C API of the core library
 * (example/Rasberry-Pi/include/led-matrix-c.h). That header is fully
 * self-contained (only pulls <stdint.h>/<stdio.h>/<stdbool.h>), so a plain
 * relative include is enough -- no extra header search paths required.
 *
 * Path: from this file (Sources/CRGBMatrix/include/) up to the
 * `example/Rasberry-Pi` root, then into `include/`.
 */
#include "../../../../../include/led-matrix-c.h"

#endif /* CRGBMATRIX_UMBRELLA_H */
