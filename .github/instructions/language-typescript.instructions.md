---
applyTo: "**/*.ts,**/*.tsx"
---

# TypeScript

## Official Documentation

When encountering unfamiliar TypeScript APIs or patterns, use a subagent to fetch
the relevant specification details from the official documentation:

- [TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/intro.html)

## Type Safety

- Enable strict mode in tsconfig. Do not disable strict compiler flags.
- Do not use `any` without an explicit justification comment. Treat untyped `any` as a bug. Use `unknown` instead of `any` as the initial type for values whose shape is not yet established.
- Use branded/opaque types for domain primitives (IDs, monetary amounts) to prevent accidental mixing.
- Use discriminated unions to model state machines and sum types. Do not use string/number enums as a substitute. Use exhaustive checks (`never` type) in switch/if-else over discriminated unions to catch missing cases at compile time.
- Use type guards and discriminated unions for type narrowing. Do not use `as` for narrowing inside business logic. Cast only at a validated runtime boundary where schema validation has already occurred.
- Use `as const` to infer literal types from object and array literals. Use the `satisfies` operator to validate a value against a type without widening it.
- Define explicit generic constraints. Do not leave unconstrained generics where a tighter bound is possible.
- Prefer `interface` over type alias for object shapes that may be extended by consumers. Use type alias for unions, intersections, and mapped types.
- Use `Readonly<T>` or `ReadonlyArray<T>` for data that must not be mutated after construction.
- Do not use `Function` or `object` as a type annotation. Use the most specific callable or object type possible.

## Architecture

- Define explicit input and output types for all public functions and API handlers. Do not rely on inferred return types at public API boundaries.
- Validate external data (API responses, environment variables, user input) with a runtime schema library (zod, io-ts) before treating it as a typed value. Validate environment variable values at application startup with a typed schema. Do not access `process.env` inline throughout the codebase.
- Co-locate domain types with the module that owns them. Do not define domain types in a global or shared utility file unless they are genuinely cross-cutting.
- Do not expose internal implementation types in public module interfaces. Keep the public surface minimal.
- Do not use type augmentation on third-party modules unless strictly necessary. Document the reason inline.
- Use type-only imports (`import type`) when importing types that are not needed at runtime.
- Do not mutate function arguments. Prefer readonly arrays and readonly object types for data passed across module or function boundaries.

## Error Handling

- Use Result/Either types or discriminated union error types for recoverable errors in library code. Do not throw for control flow.
- Do not swallow errors silently. Propagate or log with sufficient context.
- Handle `null` and `undefined` explicitly in all code paths. Do not use the non-null assertion operator (`!`) on values that could legitimately be null or undefined.
- Define error types that carry enough context for the caller to handle them. Do not use raw `Error` with only a message string for domain errors.
- Model async operation states with explicit discriminated unions (idle, loading, success, error). Do not use multiple boolean flags.
- Annotate the return type of async functions explicitly. Do not rely on inference across async boundaries.

## Testing

- Write unit tests that verify type-narrowing branches produce the correct runtime behavior.
