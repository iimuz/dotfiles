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

> **Severity model**
>
> - `abort(reason)` — halt execution immediately; do not produce partial output.
> - `warn(reason)` — log the issue and continue in degraded mode.

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

<!--
Optional: Add ## Session Artifacts section below if the skill writes output files.
Do NOT add ## Input or ## Output tables — use @param/@returns in the Interface JSDoc instead.
-->
