---
applyTo: "**/*.rs"
---

# Rust

## Official Documentation

When encountering unfamiliar Rust APIs or patterns, use a subagent to fetch
the relevant specification details from the official documentation:

- [Rust Standard Library](https://doc.rust-lang.org/std/)
- [The Rust Reference](https://doc.rust-lang.org/reference/)

## Safety

- Isolate unsafe blocks in dedicated abstraction layers. Do not use unsafe in application logic.
- Document safety invariants for every unsafe block with a SAFETY comment. Do not write unsafe code without a corresponding encapsulating safe abstraction that upholds invariants.
- Verify unsafe code produces no undefined behavior before merging. Use MIRI for this.
- Verify unsafe code paths produce no memory errors. Use address sanitizer for this.
- Document drop order dependencies when they affect correctness or resource cleanup.
- Do not expose mutable global state. Prefer dependency injection via function arguments or struct fields.
- Use type-state patterns to enforce state machine invariants at compile time.

## Error Handling

- Do not use `panic!` for recoverable errors. Return `Result` or `Option` instead. Reserve `panic!` exclusively for programmer errors such as invariant violations.
- Design public APIs to be panic-free. Document all functions that may panic explicitly in their doc comments.
- Use `?` for error propagation. Do not swallow errors silently.
- Define custom error types with `thiserror` for library crates. Use `anyhow` for error handling in application crates. Do not expose internal error details across library API boundaries without wrapping.
- Implement `Display` and `Debug` for all public error types. Implement `From` conversions to avoid manual mapping where idiomatic.

## Memory and Dependencies

- Prefer ownership transfer over cloning when performance matters. Prefer borrowing over cloning for read-only access. Do not clone data in hot paths without profiling justification.
- Commit `Cargo.lock` for binaries and applications for reproducibility. Do not commit `Cargo.lock` for library crates.
- Run `cargo audit` in CI to detect vulnerable dependencies. Do not introduce a new dependency without auditing it for soundness and maintenance status.
- Benchmark before optimizing performance-critical code paths. Use `criterion` for reproducible benchmark comparisons.

## Concurrency

- Verify `Send` + `Sync` bounds for types shared across threads. Do not share non-`Sync` types across threads.
- Use channels for orchestration and `Mutex`/`RwLock` for shared state.
- Manage thread and task lifetimes explicitly. Do not leak threads.
- Propagate context (cancellation, deadlines) through async call chains. Do not block the async executor with synchronous I/O. Use `spawn_blocking` for blocking calls.
- Pin futures that require a stable address. Document why pinning is necessary.

## Documentation

- Document all public items. Do not leave exported symbols without doc comments.

## Testing

- Write table-driven and property-based tests for correctness.
- Fuzz parsing and deserialization logic with `cargo-fuzz`.
- Use the ThreadSanitizer or race detector for concurrent code tests.
