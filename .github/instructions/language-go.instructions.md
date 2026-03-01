---
applyTo: "**/*.go"
---

# Go

## Architecture

- ALWAYS pass context.Context as the first parameter to all blocking and IO operations.
- NEVER discard a context.Context received from a caller; propagate it through the call chain.
- ALWAYS cancel contexts when they are no longer needed to avoid resource leaks.
- Accept interfaces, return concrete types; keep interfaces small and focused to a single behavior.
- Use dependency injection via interfaces to keep components testable without global state.
- Use the functional options pattern for optional configuration on exported types.
- NEVER expose large, wide interfaces; define interfaces at the consumer, not the producer.
- NEVER use init() for side effects that depend on external state or ordering guarantees.
- NEVER export identifiers that are not part of the intentional public API.

## Concurrency

- ALWAYS ensure every goroutine has a clear termination path; NEVER leak goroutines.
- ALWAYS document goroutine ownership and lifetime at the call site or in a package-level comment.
- Use channels for goroutine orchestration; use mutexes for protecting shared mutable state.
- NEVER share mutable state across goroutines without synchronization.
- ALWAYS use sync.WaitGroup or errgroup to coordinate goroutine completion.
- NEVER use goroutines inside library functions without a documented lifecycle contract.
- ALWAYS implement graceful shutdown for long-running services, honoring context cancellation.

## Error Handling

- ALWAYS wrap errors with context using fmt.Errorf("...: %w", err) or errors.Join; NEVER discard errors silently.
- ALWAYS propagate errors explicitly up the call stack; NEVER swallow errors without logging or handling.
- NEVER use panic for normal error handling; reserve panic for unrecoverable programmer errors only.
- Define sentinel errors with errors.New and custom error types with Error() string for structured handling.
- ALWAYS check errors from defer calls (e.g., Close, Commit) and propagate them to the caller.
- NEVER ignore the return value of functions that return an error.
- Use errors.Is and errors.As for error inspection; NEVER compare error strings directly.

## Testing

- ALWAYS use table-driven tests with subtests to cover edge cases and improve test readability.
- Use interfaces and dependency injection to allow unit testing without external dependencies.
- ALWAYS treat data races as correctness bugs; run tests with the race detector to surface them.
- ALWAYS test concurrent code with repeated runs to surface non-deterministic failures.

## Performance

- Use connection pooling for database and HTTP clients; NEVER create a new client per request.
- ALWAYS set appropriate timeouts on HTTP clients, servers, and database connections.
- ALWAYS pre-allocate slices and maps with make when the size is known to avoid repeated allocations.
- Use sync.Pool for frequently allocated short-lived objects in hot paths.
- NEVER use reflect or unsafe outside of well-justified, isolated packages with clear documentation.
- ALWAYS clean up resources in defer immediately after acquisition to ensure release on all code paths.

## Logging

- ALWAYS use structured logging (e.g., slog) with consistent fields; NEVER use fmt.Println for operational logs.
