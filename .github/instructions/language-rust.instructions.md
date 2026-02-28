---
applyTo: "**/*.rs"
---

# Rust

## Safety

- ALWAYS isolate unsafe blocks in dedicated abstraction layers; NEVER use unsafe in application logic.
- ALWAYS document safety invariants for every unsafe block with a SAFETY comment.
- ALWAYS verify unsafe code produces no undefined behavior before merging; use MIRI for this.
- ALWAYS verify unsafe code paths produce no memory errors; use address sanitizer for this.
- ALWAYS document drop order dependencies when they affect correctness or resource cleanup.
- NEVER write unsafe code without a corresponding encapsulating safe abstraction that upholds invariants.
- NEVER expose mutable global state; prefer dependency injection via function arguments or struct fields.
- ALWAYS use type-state patterns to enforce state machine invariants at compile time.

## Error Handling

- NEVER use panic! for recoverable errors; ALWAYS return Result or Option instead.
- ALWAYS design public APIs to be panic-free.
- ALWAYS document all functions that may panic explicitly in their doc comments.
- Reserve panic! exclusively for programmer errors such as invariant violations.
- ALWAYS use ? for error propagation; NEVER swallow errors silently.
- ALWAYS define custom error types with thiserror for library crates.
- ALWAYS use anyhow for error handling in application crates.
- NEVER expose internal error details across library API boundaries without wrapping.
- ALWAYS implement Display and Debug for all public error types.
- ALWAYS implement From conversions to avoid manual mapping where idiomatic.

## Memory

- ALWAYS prefer ownership transfer over cloning when performance matters.
- ALWAYS prefer borrowing over cloning for read-only access.
- NEVER clone data in hot paths without profiling justification.
- ALWAYS commit Cargo.lock for binaries and applications for reproducibility.
- NEVER commit Cargo.lock for library crates.
- ALWAYS run cargo audit in CI to detect vulnerable dependencies.
- NEVER introduce a new dependency without auditing it for soundness and maintenance status.
- ALWAYS benchmark before optimizing performance-critical code paths.
- ALWAYS use criterion for reproducible benchmark comparisons.

## Concurrency

- ALWAYS verify Send + Sync bounds for types shared across threads.
- NEVER share non-Sync types across threads.
- ALWAYS use channels for orchestration and Mutex/RwLock for shared state.
- ALWAYS manage thread and task lifetimes explicitly; NEVER leak threads.
- ALWAYS propagate context (cancellation, deadlines) through async call chains.
- NEVER block the async executor with synchronous I/O; use spawn_blocking for blocking calls.
- ALWAYS pin futures that require a stable address; document why pinning is necessary.
- ALWAYS use the ThreadSanitizer or race detector for concurrent code tests.

## Testing

- ALWAYS write table-driven and property-based tests for correctness.
- ALWAYS fuzz parsing and deserialization logic with cargo-fuzz.

## Documentation

- ALWAYS document all public items; NEVER leave exported symbols without doc comments.
