# Testing Anti-Patterns

Avoid common testing mistakes that reduce test value and maintainability.

## Testing Mock Behavior Instead of Real Behavior

**Problem**: Tests verify mock interactions rather than actual code behavior.

**Detection**:
- Tests call `expect(mock).toHaveBeenCalledWith(...)`
- Tests focus on mock setup more than assertions
- Implementation changes break tests even when behavior is correct

**Remediation**:
- Test real code paths with minimal mocking
- Mock only external dependencies (APIs, databases, time)
- Assert on observable outcomes, not internal calls

## Adding Test-Only Methods to Production Classes

**Problem**: Production code includes methods solely for testing convenience.

**Detection**:
- Methods named `setTestMode()`, `getInternalState()`, `resetForTesting()`
- Public methods never called in production
- Documentation states "for testing only"

**Remediation**:
- Use dependency injection to expose internal dependencies
- Test through public API only
- Extract testable logic into separate pure functions

## Testing Implementation Details

**Problem**: Tests couple to how code works instead of what it does.

**Detection**:
- Tests break when refactoring without behavior change
- Tests access private fields or methods
- Tests verify internal data structures

**Remediation**:
- Test observable behavior from caller's perspective
- Treat implementation as black box
- Focus on inputs, outputs, and side effects

## Over-Mocking Dependencies

**Problem**: Excessive mocking creates brittle tests disconnected from reality.

**Detection**:
- Mock setup exceeds actual test logic
- Mocking components that could run in-process
- Tests pass but integration fails

**Remediation**:
- Use real implementations for fast in-process dependencies
- Reserve mocks for slow/unreliable external systems
- Prefer test doubles over mocking frameworks when possible

## Excessive Fixture Setup

**Problem**: Large setup blocks obscure test intent and create maintenance burden.

**Detection**:
- Setup blocks exceed 10 lines
- Multiple tests share complex fixtures
- Changing one test breaks unrelated tests

**Remediation**:
- Extract setup helpers with clear names
- Use builder pattern for test data
- Duplicate setup rather than share when unclear
- Consider if design is too complex to test
