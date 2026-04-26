# TypeScript

- Official docs: [Handbook](https://www.typescriptlang.org/docs/handbook/intro.html)
- Enable strict mode. Do not use `any` without an explicit justification comment. Use `unknown` instead.
- Use branded types for domain primitives (IDs, monetary amounts).
- Use discriminated unions for state machines and error types. Use exhaustive checks with `never`.
- Use `as const` and `satisfies` for literal type inference without widening.
- Use `Readonly<T>` and `ReadonlyArray<T>` for immutable data. Do not mutate function arguments.
- Use `import type` for type-only imports.
- Validate external data with a runtime schema library (zod, io-ts) at the boundary.
- Validate environment variables at startup with a typed schema. Do not access `process.env` inline.
- Use Result or discriminated union error types for recoverable errors. Do not throw for control flow.
- Model async states with discriminated unions (idle, loading, success, error). Do not use boolean flags.
