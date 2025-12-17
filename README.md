# Demonstration of rust-lang/rust#142119

https://github.com/rust-lang/rust/issues/142119

## The Issue

A regression was introduced in Rust 1.87 where linking a Rust staticlib unexpectedly causes C math functions to resolve to `compiler-builtins` implementations instead of system libm. This breaks IEEE 754 semantics for signaling NaN (sNaN) handling.

## Reproduction

```
$ make test
Building with Rust 1.86.0 (expected behavior)...
nm target/release/librust_libm_issue.a | grep "ceil" || true
Building with Rust 1.87.0 (regression)...
nm target/release/librust_libm_issue.a | grep "ceil" || true
0000000000000000 T _ZN17compiler_builtins4math4libm7generic4ceil11ceil_status17h019be2039912dad4E
0000000000000000 T _ZN17compiler_builtins4math4libm7generic4ceil11ceil_status17h10ec01d63e6b003cE
0000000000000000 T _ZN17compiler_builtins4math4libm7generic4ceil11ceil_status17h3d5b5dbd795777b7E
0000000000000000 T _ZN17compiler_builtins4math4libm7generic4ceil11ceil_status17he4bc424bc2db414bE
0000000000000000 T _ZN17compiler_builtins4math17full_availability4ceil17h1c9f12846f3db1adE
0000000000000000 T _ZN17compiler_builtins4math17full_availability5ceilf17h588e4ac68821f452E
0000000000000000 T _ZN17compiler_builtins4math4libm4ceil4ceil17hb492647ffc38bb41E
0000000000000000 W ceilf16
0000000000000000 W ceilf128
0000000000000000 T _ZN17compiler_builtins4math4libm5ceilf5ceilf17hc3a980dd55a1152bE
0000000000000000 W ceil
0000000000000000 W ceilf
make[1]: Entering directory '/home/ethompson/src/rust_libm_issue'

==========================================
RUST 1.86.0 - Uses glibc libm (CORRECT)
==========================================
ceil symbol:                  U ceil@GLIBC_2.2.5
ldd:
        linux-vdso.so.1 (0x00007d6be5ef5000)
        libm.so.6 => /lib/x86_64-linux-gnu/libm.so.6 (0x00007d6be5dee000)
        libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007d6be5a00000)
        /lib64/ld-linux-x86-64.so.2 (0x00007d6be5ef7000)

Input:  0xfff0000000000001 (sNaN)
Output: 0xfff8000000000001 (qNaN)
FPE flags: INVALID


==========================================
RUST 1.87.0 - Uses compiler-builtins (REGRESSION)
==========================================
ceil symbol: 0000000000001350 t ceil
ldd:
        linux-vdso.so.1 (0x000073369bdf1000)
        libm.so.6 => /lib/x86_64-linux-gnu/libm.so.6 (0x000073369bcea000)
        libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x000073369ba00000)
        /lib64/ld-linux-x86-64.so.2 (0x000073369bdf3000)

Input:  0xfff0000000000001 (sNaN)
Output: 0xfff0000000000001 (sNaN)
FPE flags: (none)
make[1]: Leaving directory '/home/ethompson/src/rust_libm_issue'
```
