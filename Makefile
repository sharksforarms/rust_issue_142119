.PHONY: all clean test compare workaround

all: test

# Build and run comparison test
test:
	@echo "Building with Rust 1.86.0 (expected behavior)..."
	@rustup run 1.86.0 cargo build --release 2>&1 | grep -v "Compiling\|Finished" || true
	nm target/release/librust_libm_issue.a | grep "ceil" || true
	@gcc -o test-1.86 test.c -L./target/release -lrust_libm_issue -lm
	@echo "Building with Rust 1.87.0 (regression)..."
	@rustup run 1.87.0 cargo build --release 2>&1 | grep -v "Compiling\|Finished" || true
	nm target/release/librust_libm_issue.a | grep "ceil" || true
	@gcc -o test-1.87 test.c -L./target/release -lrust_libm_issue -lm
	@$(MAKE) compare

compare:
	@echo "\n=========================================="
	@echo "RUST 1.86.0 - Uses glibc libm (CORRECT)"
	@echo "=========================================="
	@echo "ceil symbol: $$(nm test-1.86 | grep ceil)"
	@echo "ldd:\n$$(ldd test-1.86)"
	@echo ""
	@./test-1.86
	@echo "\n\n=========================================="
	@echo "RUST 1.87.0 - Uses compiler-builtins (REGRESSION)"
	@echo "=========================================="
	@echo "ceil symbol: $$(nm test-1.87 | grep ceil)"
	@echo "ldd:\n$$(ldd test-1.87)"
	@echo ""
	@./test-1.87

workaround:
	@echo "Building with Rust 1.87.0 (workaround) (-lm before -lrustlib)"
	@rustup run 1.87.0 cargo build --release 2>&1 | grep -v "Compiling\|Finished" || true
	@gcc -o test-workaround test.c -lm -L./target/release -lrust_libm_issue
	@echo "ceil symbol: $$(nm test-workaround | grep ceil)"
	@echo "ldd:\n$$(ldd test-workaround)"
	@echo ""
	@./test-workaround

clean:
	cargo clean
	rm -f test-1.86 test-1.87 test-workaround
