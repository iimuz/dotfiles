---
name: tdd-workflow-green
description: Implements minimal code to pass failing tests with proof.
user-invocable: false
disable-model-invocation: false
---

# TDD Workflow: Green

## Overview

Implement only the smallest production change required to satisfy a verified Red test and prove all tests are green afterward.

## Interface

```typescript
/**
 * @skill tdd-workflow-green
 * @input  { unitSpec: string; redFailureProof: { command: string; observedFailure: string }; testCommand: string; implementationPath: string }
 * @output { implementationFile: string; passProof: { command: string; summary: string; evidence: string } }
 *
 * @invariants
 * - invariant: (task_call_attempted) => abort("Sub-skill must not call task() or spawn nested sub-agents");
 */
type GreenInput = {
  unitSpec: string;
  redFailureProof: {
    command: string;
    observedFailure: string;
  };
  testCommand: string;
  implementationPath: string;
};

type GreenOutput = {
  implementationFile: string;
  passProof: {
    command: string;
    summary: string;
    evidence: string;
  };
};
```

For Green constraints and guardrails, read [references/tdd-rules.md](references/tdd-rules.md) before editing code.

## Operations

```typespec
op validateRedProof(input: GreenInput) -> GreenInput {
  // Confirm redFailureProof is present and shows expected failing-test evidence for unitSpec.
  // Reject execution when proof is missing, empty, or unrelated to the target behavior.
  fault(red_proof_absent) => fallback: none; abort
}

op implementMinimalProductionCode(input: GreenInput) -> { implementationFile: string } {
  // Edit only implementationPath and keep behavior strictly limited to unitSpec.
  // Do not add unrelated features, refactors, or speculative extensions.
  fault(unrelated_behavior_added) => fallback: none; abort
}

op verifyGreen(input: GreenInput) -> { passProof: { command: string; summary: string; evidence: string } } {
  // Run testCommand and collect structured proof that all tests pass after implementation.
  // passProof must include command used, a one-line summary, and raw test output evidence.
  // Ensure output indicates complete green status, not partial success.
  fault(tests_still_fail) => fallback: none; abort
}
```

## Execution

```text
validateRedProof -> implementMinimalProductionCode -> verifyGreen
```

## Output

- implementationFile: path to the updated production file.
- passProof: structured proof with command, one-line summary, and raw evidence that all tests pass.

## Examples

### Happy Path

- Input: unitSpec, redFailureProof, testCommand, implementationPath provided.
- validateRedProof succeeds with clear failing-test evidence.
- implementMinimalProductionCode updates only implementationPath.
- verifyGreen confirms all tests pass; returns implementationFile and structured passProof.

### Failure Path

- Input omits redFailureProof.
- validateRedProof triggers hard gate.
- fault(red_proof_absent) => fallback: none; abort.
