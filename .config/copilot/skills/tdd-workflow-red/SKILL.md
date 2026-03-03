---
name: tdd-workflow-red
description: Writes one failing test with verified red-phase failure proof.
user-invocable: false
disable-model-invocation: false
---

# TDD Workflow: Red

## Overview

Create one failing test for one TDD unit and prove it fails for the expected reason.

Read the red-phase guardrails before execution: [tdd-rules.md](references/tdd-rules.md)

## Interface

```typescript
/**
 * @skill tdd-workflow-red
 * @input  { unitSpec: { behavior: string; testPath: string; command: string; expectedFailure: string } }
 * @output { testFile: string; failureProof: { command: string; observedFailure: string } }
 *
 * @invariants
 * - invariant: (task_call_attempted) => abort("Sub-skill must not call task() or spawn nested sub-agents");
 */

type RedInput = {
  unitSpec: {
    behavior: string;
    testPath: string;
    testCommand: string;
    expectedFailure: string;
  };
};

type RedOutput = {
  testFile: string;
  failureProof: {
    command: string;
    observedFailure: string;
  };
};
```

## Operation

```typespec
op writeFailingTest(input: RedInput) -> RedOutput {
  // Write exactly one new test that covers only unitSpec.behavior
  // Run unitSpec.testCommand scoped to the new test at unitSpec.testPath
  // Capture failing output and return proof with test path and observed failure reason

  fault(testDidNotFail) => fallback: none; abort
  fault(failureReasonMismatch) => fallback: none; abort
}
```

## Examples

### Happy Path

- Input: unitSpec for missing retry backoff behavior with expectedFailure "Expected 3 retries, received 1"
- Action: write one test at tests/retry.test.ts and run `npm test tests/retry.test.ts`
- Output: testFile path plus failureProof containing matching expected failure reason

### Failure Path

- Input: unitSpec where expectedFailure is "missing validation error"
- Action: test run fails with "cannot find module" instead
- Result: fault(failureReasonMismatch) => fallback: none; abort
