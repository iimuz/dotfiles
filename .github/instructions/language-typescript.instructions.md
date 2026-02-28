---
applyTo: "**/*.ts,**/*.tsx"
---

# TypeScript

## Type Safety

- ALWAYS enable strict mode in tsconfig; NEVER disable strict compiler flags.
- NEVER use any without an explicit justification comment; treat untyped any as a bug.
- ALWAYS use unknown instead of any as the initial type for values whose shape is not yet established.
- ALWAYS use branded/opaque types for domain primitives (IDs, monetary amounts) to prevent accidental mixing.
- ALWAYS use discriminated unions to model state machines and sum types; NEVER use string/number enums as a substitute.
- ALWAYS use exhaustive checks (never type) in switch/if-else over discriminated unions to catch
  missing cases at compile time.
- ALWAYS use type guards and discriminated unions for type narrowing; NEVER use as for narrowing inside business logic.
- NEVER cast external data with as; cast only at a validated runtime boundary where schema validation has already occurred.
- ALWAYS use const assertions (as const) to infer literal types from object and array literals.
- ALWAYS use the satisfies operator to validate a value against a type without widening it.
- ALWAYS define explicit generic constraints; NEVER leave unconstrained generics where a tighter bound is possible.
- ALWAYS prefer interface over type alias for object shapes that may be extended by consumers;
  use type alias for unions, intersections, and mapped types.
- ALWAYS use `Readonly<T>` or `ReadonlyArray<T>` for data that must not be mutated after construction.
- NEVER use Function or object as a type annotation; always use the most specific callable or object type possible.

## Architecture

- ALWAYS define explicit input and output types for all public functions and API handlers.
- NEVER rely on inferred return types at public API boundaries.
- ALWAYS validate external data (API responses, environment variables, user input) with a runtime
  schema library (zod, io-ts) before treating it as a typed value.
- ALWAYS validate environment variable values at application startup with a typed schema; NEVER
  access process.env inline throughout the codebase.
- ALWAYS co-locate domain types with the module that owns them; NEVER define domain types in a
  global or shared utility file unless they are genuinely cross-cutting.
- NEVER expose internal implementation types in public module interfaces; keep the public surface minimal.
- NEVER use type augmentation on third-party modules unless strictly necessary; document the reason inline.
- ALWAYS use type-only imports (import type) when importing types that are not needed at runtime.
- NEVER mutate function arguments.
- ALWAYS prefer readonly arrays and readonly object types for data passed across module or function boundaries.

## Error Handling

- ALWAYS use Result/Either types or discriminated union error types for recoverable errors in
  library code; NEVER throw for control flow.
- NEVER swallow errors silently; always propagate or log with sufficient context.
- ALWAYS handle null and undefined explicitly in all code paths.
- NEVER use the non-null assertion operator (!) on values that could legitimately be null or undefined.
- ALWAYS define error types that carry enough context for the caller to handle them; NEVER use raw
  Error with only a message string for domain errors.
- ALWAYS model async operation states with explicit discriminated unions (idle, loading, success,
  error); NEVER use multiple boolean flags.
- ALWAYS annotate the return type of async functions explicitly; NEVER rely on inference across
  async boundaries.

## Testing

- ALWAYS write unit tests that verify type-narrowing branches produce the correct runtime behavior.
