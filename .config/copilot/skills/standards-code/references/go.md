# Go

## Official Documentation

When encountering unfamiliar Go APIs or patterns, use a subagent to fetch
the relevant specification details from the official documentation:

- [Effective Go](https://go.dev/doc/effective_go)
- [Go Standard Library](https://pkg.go.dev/std)

## Architecture

- Pass `context.Context` as the first parameter to all blocking and IO
  operations. Do not discard a context received from a caller. Cancel contexts
  when they are no longer needed to avoid resource leaks.
- Accept interfaces, return concrete types. Keep interfaces small and focused to
  a single behavior. Define interfaces at the consumer, not the producer.
- Use dependency injection via interfaces to keep components testable without global state.
- Use the functional options pattern for optional configuration on exported types.
- Do not use `init()` for side effects that depend on external state or ordering guarantees.
- Do not export identifiers that are not part of the intentional public API.

## Concurrency

- Ensure every goroutine has a clear termination path. Do not leak goroutines.
- Document goroutine ownership and lifetime at the call site or in a package-level comment.
- Use channels for goroutine orchestration. Use mutexes for protecting shared
  mutable state. Do not share mutable state across goroutines without
  synchronization.
- Use `sync.WaitGroup` or `errgroup` to coordinate goroutine completion.
- Do not use goroutines inside library functions without a documented lifecycle contract.
- Implement graceful shutdown for long-running services, honoring context cancellation.

## Error Handling

- Wrap errors with context using `fmt.Errorf("...: %w", err)` or `errors.Join`. Do not discard errors silently.
- Propagate errors explicitly up the call stack. Check errors from defer calls
  (e.g., `Close`, `Commit`) and propagate them to the caller. Do not ignore the
  return value of functions that return an error.
- Do not use `panic` for normal error handling. Reserve panic for unrecoverable programmer errors only.
- Define sentinel errors with `errors.New` and custom error types with
  `Error() string` for structured handling. Use `errors.Is` and `errors.As`
  for error inspection. Do not compare error strings directly.

## Performance

- Use connection pooling for database and HTTP clients. Do not create a new client per request.
- Set appropriate timeouts on HTTP clients, servers, and database connections.
- Pre-allocate slices and maps with `make` when the size is known to avoid repeated allocations.
- Use `sync.Pool` for frequently allocated short-lived objects in hot paths.
- Do not use `reflect` or `unsafe` outside of well-justified, isolated packages with clear documentation.
- Clean up resources in defer immediately after acquisition to ensure release on all code paths.

## Logging

- Use structured logging (e.g., `slog`) with consistent fields. Do not use `fmt.Println` for operational logs.

## Testing

- Use table-driven tests with subtests to cover edge cases and improve test readability.
- Use interfaces and dependency injection to allow unit testing without external dependencies.
- Treat data races as correctness bugs. Run tests with the race detector to surface them.
- Test concurrent code with repeated runs to surface non-deterministic failures.
