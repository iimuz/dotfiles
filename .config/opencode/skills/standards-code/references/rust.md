# Rust

- Official docs: [Standard Library](https://doc.rust-lang.org/std/), [Reference](https://doc.rust-lang.org/reference/)
- Isolate `unsafe` in dedicated abstraction layers. Document safety invariants with a SAFETY comment.
- Return `Result` or `Option` for recoverable errors. Reserve `panic!` for invariant violations only.
- Use `thiserror` for library crates, `anyhow` for application crates.
- Use `?` for propagation. Implement `Display` and `Debug` for public error types.
- Depend on trait bounds, not concrete types. Use type-state patterns for state machine invariants.
- Prefer ownership transfer over cloning in hot paths. Prefer borrowing for read-only access.
- Verify `Send` + `Sync` bounds for types shared across threads.
- Use `spawn_blocking` for blocking calls in async context.
- Commit `Cargo.lock` for binaries only. Run `cargo audit` in CI.
- Document all public items. Fuzz parsing logic with `cargo-fuzz`.
