# Output Template: Canonical Skill Format

Canonical structure for transformed skills. Every output must conform to this template.
Reference: `.config/copilot/skills/references/canonical-skill-template.md`

---

## Template Structure

```text
---
name: <skill-name>
description: <One-sentence description. Use third-person: "This skill should be used when...">
---

# <Skill Title>

## Role

<One paragraph describing the skill's purpose, domain, and when to invoke it.>

## Interface

\`\`\`typescript
/**
 * @skill <skill-name>
 * @input  { <input_param>: <InputType> }
 * @output { <output_param>: <OutputType> }
 */

type <InputType> = {
  <field>: <Type>;
};

type <OutputType> = {
  <field>: <Type>;
};

/**
 * @invariants
 * - invariant: (<condition>) => abort("<reason>");   // halts execution
 * - invariant: (<condition>) => warn("<reason>");    // logs and continues in degraded mode
 */
\`\`\`

> **Severity model**
> - `abort(reason)` — halt execution immediately; do not produce partial output.
> - `warn(reason)` — log the issue and continue in degraded mode.

## Operations

\`\`\`typespec
op <step_one>(<param>: <Type>) -> <IntermediateType> {
  // Brief description of what this op does
  invariant: (<precondition_missing>) => abort("<Required precondition not met>");
  invariant: (<recoverable_issue>) => warn("<Proceeding with defaults>");
}

op <step_two>(intermediate: <IntermediateType>) -> <OutputType> {
  // Brief description of what this op does
  invariant: (<fatal_condition>) => abort("<Cannot produce output>");
}
\`\`\`

## Execution

\`\`\`text
<step_one> -> <step_two>
\`\`\`

| dependent       | prerequisite    | description                               |
|-----------------|-----------------|-------------------------------------------|
| *(column key)*  | *(column key)*  | *(dependent requires prerequisite first)* |
| <step_two>      | <step_one>      | <step_two> consumes output of <step_one>  |

## Input

| Field             | Type           | Required | Description                   |
|-------------------|----------------|----------|-------------------------------|
| `<input_param>`   | `<InputType>`  | yes      | <What this input represents>  |

## Output

| Field              | Type            | Description                     |
|--------------------|-----------------|---------------------------------|
| `<output_param>`   | `<OutputType>`  | <What this output represents>   |
```

---

## Complete Example: `council` Skill Transformed

**Source (Legacy)**: The `council` skill with `## Workflow`, `## Council Configuration`, and `## Error Handling` sections.

**Output (Spec-First Hybrid)**:

---

```markdown
---
name: council
description: >
  Produce high-quality answers by synthesizing perspectives from multiple LLMs through
  parallel response generation, anonymized peer review, and chairman synthesis.
  Use for complex questions benefiting from collective deliberation.
---

# LLM Council
```

## Interface

```typescript
/**
 * @skill council
 * @input  { question: string }
 * @output { synthesis: string }
 */

type Response = { model: string; content: string; filepath: string };
type Review = { reviewer: string; ranking: number[]; filepath: string };
type LabelMapping = Record<string, string>; // response-label -> model-name

type ModelRoles = {
  Member1: "claude-opus-4.6";
  Member2: "gemini-3-pro-preview";
  Member3: "gpt-5.3-codex";
  Chairman: "claude-opus-4.6";
};

/**
 * @invariants
 * 1. Zero_Verbosity:      no imperative step text in op bodies
 * 2. Signature_Integrity: all ops fully typed
 * 3. Minimal_Token:       model names via ModelRoles type only
 */
```

## Operations

```typespec
op generate_responses(question: string) -> Response[] {
  task(model: ModelRoles.Member1 | ModelRoles.Member2 | ModelRoles.Member3, prompt: @references/stage1-prompt.md);
  invariant: (count < 2)  => abort("Council quorum not met");
  invariant: (count == 2) => warn("Degraded mode: 2/3 responses available");
}

op anonymize(responses: Response[]) -> { labeled: LabeledContent; mapping: LabelMapping } {
  task(model: "claude-sonnet-4.6", prompt: @references/stage2-prep-prompt.md);
  invariant: (mapping_missing) => fallback(synthesize_fallback(responses));
}

op peer_review(question: string, labeled: LabeledContent) -> Review[] {
  task(model: ModelRoles.Member1 | ModelRoles.Member2 | ModelRoles.Member3, prompt: @references/stage2-prompt.md);
  invariant: (valid_reviews < 2) => warn("Reduced review coverage");
}

op aggregate_rankings(reviews: Review[], mapping: LabelMapping) -> RankingTable {
  task(model: "claude-sonnet-4.6", prompt: @references/ranking-aggregation-prompt.md);
  invariant: (aggregate_fails) => passthrough("proceed without rankings");
}

op synthesize(
  question: string,
  responses: Response[],
  reviews:   Review[],
  rankings:  RankingTable
) -> string {
  task(model: ModelRoles.Chairman, prompt: @references/stage3-prompt.md);
  invariant: (chairman_fails) => fallback(@references/fallback-synthesis-prompt.md);
}
```

## Execution

```text
generate_responses -> anonymize -> peer_review -> aggregate_rankings -> synthesize
```

Present `synthesize` output directly to user. Main agent must not read intermediate files.

---

## Reference File Template

Reference files containing subagent prompts use the same Hybrid-3 op/invariant notation for both the outer scaffolding
(invocation and failure handling) and the inner prompt content (role, typed I/O, ops, execution pipeline).

### Complete Example: `stage1-prompt.md`

```markdown
# Outer Scaffolding

## Invocation

op invoke_stage1(question: string, model: ModelRoles.Member) -> Response {
task(agent_type: "general-purpose", prompt: rendered_template(question));
invariant: (response_empty) => retry(max: 1, then: mark_failed(model));
invariant: (timeout > 120s) => abort_member(model);
}

## Failure Handling

op handle_stage1_failure(failed: ModelRoles.Member[], responses: Response[]) -> Response[] {
invariant: (len(responses) < 2) => abort("Council quorum not met");
invariant: (len(responses) == 2) => warn("Degraded mode: 2/3 responses");
}

---

# Subagent Prompt Template

## Role

You are an expert analyst contributing to a multi-model council deliberation.

## Interface

\`\`\`typescript
/\*\*

- @input { question: string }
- @output { analysis: string }
  \*/

type AnalysisOutput = {
reasoning: string;
conclusion: string;
confidence: "high" | "medium" | "low";
};
\`\`\`

## Operations

\`\`\`typespec
op analyze_question(question: string) -> AnalysisOutput {
invariant: (question_ambiguous) => state_assumptions_explicitly;
invariant: (domain_outside_expertise) => declare_limitation;
}

op structure_response(analysis: AnalysisOutput) -> string {
invariant: (conclusion_unsupported) => add_caveats;
}
\`\`\`

## Execution

analyze_question -> structure_response

## Input Context

Question: {{question}}

Provide your independent analysis. Do not reference other models or prior answers.
```

---

## Notes on Format Compliance

1. **YAML frontmatter is mandatory** — `name` and `description` fields required for skill discovery.
2. **Section order is canonical** — `Role`, `Interface`, `Operations`, `Execution`, `Input`, `Output` in that order.
3. **Interface block uses TypeScript syntax** — typed via `type` declarations, not `interface`.
4. **Operations block uses TypeSpec-flavor** — `op name(params) -> ReturnType { invariants }`.
5. **Invariants are anonymous only** — `invariant: (condition) => action;` syntax; no numbered named invariants in op bodies.
6. **Severity model** — only `abort(reason)` (halt) and `warn(reason)` (degraded continue) are permitted.
7. **Invariants are per-op** — place each `invariant:` line in the op that owns the condition.
8. **Cross-op invariants** belong in the `@invariants` JSDoc comment in the Interface block.
9. **Dependency table required** — `## Execution` must include a `dependent | prerequisite | description` table with legend row and example row.
10. **Reference stubs** — every `@references/file.md` citation requires a corresponding file.
11. **Reference file format** — Reference files containing subagent prompts must use canonical format. Both outer scaffolding and inner prompt content use op/invariant notation.
