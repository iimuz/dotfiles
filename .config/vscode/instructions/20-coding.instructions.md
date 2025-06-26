---
applyTo: "**"
---

# Coding Practices

## Principles

### Functional Approach (FP)

- Prioritize pure functions
- Use immutable data structures
- Isolate side effects
- Ensure type safety

### Domain-Driven Design (DDD)

- Distinguish between Value Objects and Entities
- Ensure consistency with Aggregates
- Abstract data access with Repositories
- Be aware of Bounded Contexts

### Test-Driven Development (TDD)

- Red-Green-Refactor cycle
- Treat tests as specifications
- Iterate in small units
- Continuous refactoring

## Implementation Patterns

### Type Definitions

```typescript
// Ensure type safety with Branded Types
type Branded<T, B> = T & { _brand: B };
type Money = Branded<number, "Money">;
type Email = Branded<string, "Email">;
```

### Value Objects

- Immutable
- Identity based on value
- Self-validating
- Have domain operations

```typescript
// Creation function with validation
function createMoney(amount: number): Result<Money, Error> {
  if (amount < 0) return err(new Error("Negative amounts not allowed"));
  return ok(amount as Money);
}
```

### Entities

- Identity based on ID
- Controlled updates
- Have consistency rules

### Result Type

```typescript
type Result<T, E> = { ok: true; value: T } | { ok: false; error: E };
```

- Explicitly indicate success/failure
- Use early return pattern
- Define error types

### Repositories

- Deal only with the domain model
- Hide persistence details
- Provide in-memory implementations for testing

### Adapter Pattern

- Abstract external dependencies
- Interfaces defined by the caller
- Easily replaceable during testing

## Implementation Steps

1. **Type Design**
   - Define types first
   - Express domain language with types
2. **Implement Pure Functions First**
   - Implement functions without external dependencies first
   - Write tests first
3. **Isolate Side Effects**
   - Push IO operations to the boundaries of functions
   - Wrap processes with side effects in Promises
4. **Adapter Implementation**
   - Abstract access to external services or DBs
   - Prepare mocks for testing

## Practices

- Start small and expand incrementally
- Avoid excessive abstraction
- Prioritize types over code
- Adjust approach according to complexity

## Code Style

- Prefer functions (use classes only when necessary)
- Utilize immutable update patterns
- Flatten conditional branches with early returns
- Define enums for errors and use cases

## Test Strategy

- Prioritize unit tests for pure functions
- Repository tests with in-memory implementations
- Incorporate testability into design
- Assert-first: work backward from expected results
