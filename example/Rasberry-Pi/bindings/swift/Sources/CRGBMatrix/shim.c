/*
 * SwiftPM requires a C target to have at least one source file. The actual
 * symbols come from the prebuilt librgbmatrix.a (linked by the executables);
 * this translation unit only needs to make the module's headers compile.
 */
#include "include/CRGBMatrix.h"
