---
name: { skill-name }
description:
  {
    One-sentence description. Use third-person: "This skill should be used when...",
  }
---

# {Skill Title}

## Role

{One paragraph describing the skill's purpose, domain, and when to invoke it.}

## Interface

```typescript
/**
 * @skill {skill-name}
 * @input  { {input_field}: {InputType} }
 * @output { {output_field}: {OutputType} }
 *
 * @param {input_field}   {What this input represents} (required | optional)
 * @returns {output_field}  {What this output represents}
 */

type {InputType} = {
  {field}: {type};
};

type {OutputType} = {
  {field}: {type};
};

/**
 * @invariants
 * - invariant: ({condition}) => abort("{reason}");   // halts execution
 * - invariant: ({condition}) => warn("{reason}");    // logs and continues in degraded mode
 */
```

Severity model:

- abort(reason): halt execution immediately; do not produce partial output.
- warn(reason): log the issue and continue in degraded mode.

<!--
Skill type: this structure represents the knowledge/transform authoring track
(single op chain, no task() calls or sub-skill delegation).

For workflow skills, replace ## Operations with numbered delegation stages and use:
  fault(<condition>) => fallback: <action>; <continue|abort>
at the end of each stage block instead of op-level invariants.
For consistency checks between two independently produced values, use:
  assert(<left> != <right>) => on_conflict: <resolution>; <continue|abort>
Coordinator-only discipline: a workflow skill must not be invoked as a sub-skill by another
workflow skill unless an explicit orchestrator-delegation contract is declared in both SKILL.md files.
-->

## Operations

```typespec
op {step_one}(input: {InputType}) -> {IntermediateType} {
  // {Brief description of what this op does}
  invariant: ({precondition_missing}) => abort("{Required precondition not met}");
  invariant: ({recoverable_issue}) => warn("{Proceeding with defaults}");
}

op {step_two}(intermediate: {IntermediateType}) -> {OutputType} {
  // {Brief description of what this op does}
  invariant: ({fatal_condition}) => abort("{Cannot produce output}");
}
```

## Execution

```text
{step_one} -> {step_two}
```

| dependent      | prerequisite   | description                               |
| -------------- | -------------- | ----------------------------------------- |
| _(column key)_ | _(column key)_ | _(dependent requires prerequisite first)_ |
| {step_two}     | {step_one}     | {step_two} consumes output of {step_one}  |

## Examples

### Happy Path

- Input: { {input_field}: {example_valid_value} }
- Result: {brief description of successful outcome, e.g., output file written to {output_field}}

### Failure Path

- Input: { {input_field}: {example_invalid_or_missing_value} }
- Result: abort("{reason}") or warn("{reason}"); degraded output if applicable

<!--
Optional: Add ## Session Artifacts section below if the skill writes output files.
Do NOT add ## Input or ## Output tables — use @param/@returns in the Interface JSDoc instead.
Required for all skill types: include ## Examples with ### Happy Path and ###
Failure Path; limit each subsection to 5 lines or fewer.
For workflow skills: every sub-skill delegated to must also include ## Examples with ### Happy Path and ### Failure Path.
-->
