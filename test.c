#include <math.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <fenv.h>

void demo();

void print_fpe_flags() {
    int flags = fetestexcept(FE_ALL_EXCEPT);
    printf("FPE flags: ");
    if (flags & FE_INVALID) printf("INVALID ");
    if (flags & FE_DIVBYZERO) printf("DIVBYZERO ");
    if (flags & FE_OVERFLOW) printf("OVERFLOW ");
    if (flags & FE_UNDERFLOW) printf("UNDERFLOW ");
    if (flags & FE_INEXACT) printf("INEXACT ");
    if (!flags) printf("(none)");
    printf("\n");
}

int main(int argc, char** argv) {
    // Test sNaN from Chromium issue rust-lang/rust#142119
    double snan;
    uint64_t snan_bits = 0xFFF0000000000001ULL;
    memcpy(&snan, &snan_bits, sizeof(double));

    feclearexcept(FE_ALL_EXCEPT);  // Clear flags before test
    double result = ceil(snan);

    uint64_t result_bits;
    memcpy(&result_bits, &result, sizeof(double));

    printf("Input:  0x%016lx (sNaN)\n", snan_bits);
    printf("Output: 0x%016lx %s\n", result_bits,
           (result_bits & 0x0008000000000000ULL) ? "(qNaN)" : "(sNaN)");
    print_fpe_flags();

    return 0;
}
