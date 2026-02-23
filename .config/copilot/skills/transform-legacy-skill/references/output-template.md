# Output Template: Spec-First Hybrid (Hybrid-3) Skill Format

Canonical structure for transformed skills. Every output must conform to this template.

---

## Template Structure

```text
---
name: <skill-name>
description: <goal-only description, 1-2 sentences>
---

# <Skill Title>

## Overview

<1-2 sentences: what this skill enables>

## Interface

\`\`\`typescript
/**
 * @skill <skill-name>
 * @input  { <input_param>: <Type> }
 * @output { <output_param>: <Type> }
 */

type <PrimaryEntity> = {
  <field>: <Type>;
  // ...
};

type MappingRegistry = {
  // Include only if skill has model configurations
  "<legacy-model>": "<current-model>";
};

/**
 * @invariants
 * 1. Zero_Verbosity:      imperative sentences => remove
 * 2. Signature_Integrity: every op => typed (input: T) -> U
 * 3. Minimal_Token:       prose => symbolic notation
 */
\`\`\`

## Operations

\`\`\`typespec
op <operation_name>(<param>: <Type>) -> <ReturnType> {
  // Single-line description of computation
  invariant: (<condition>) => <action>;
}
// ... (one op per logical transformation stage)
\`\`\`

## Execution

<Pipeline expressed in one line>:
\`\`\`
op1 -> op2 -> [op3 + op4] -> op5
\`\`\`

<One sentence describing how to present output.>
Reference: [\`references/<resource>.md\`](references/<resource>.md)
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
2. **Interface block uses TypeScript syntax** — typed via `type` declarations, not `interface`.
3. **Operations block uses TypeSpec-flavor** — `op name(params) -> ReturnType { invariants }`.
4. **Invariants are per-op** — place each `invariant:` line in the op that owns the condition.
5. **Cross-op invariants** belong in the `@invariants` JSDoc comment in the Interface block.
6. **Reference stubs** — every `@references/file.md` citation requires a corresponding file.
7. **Reference file format** — Reference files containing subagent prompts must use Hybrid-3 format. Both outer
   scaffolding and inner prompt content use op/invariant notation. Plain-text code fence wrappers around entire
   templates are prohibited.
