# Go

- Official docs: [Effective Go](https://go.dev/doc/effective_go), [Standard Library](https://pkg.go.dev/std)
- Pass `context.Context` as the first parameter to all blocking and IO operations.
- Accept interfaces, return concrete types. Define interfaces at the consumer.
- Use functional options pattern for optional configuration.
- Wrap errors with `fmt.Errorf("...: %w", err)`. Define sentinel errors with `errors.New`.
- Use `errors.Is` and `errors.As` for inspection. Do not compare error strings.
- Ensure every goroutine has a clear termination path. Use `errgroup` for coordination.
- Pre-allocate slices and maps with `make` when size is known.
- Use `slog` for structured logging.
- Use table-driven tests with subtests. Run tests with the race detector.
