---
name: transform-legacy-skill
description: Transform agentskills.io Markdown-format Skill definitions (2023-2024 procedural style) into Spec-First Hybrid (TypeScript/TypeSpec) format optimized for 2026 reasoning models. This skill should be used when modernizing legacy skill files that use step-by-step workflow instructions, converting them into declarative op-based specifications with typed interfaces and invariant conditions.
---

# Transform Legacy Skill

## Overview

Convert a legacy procedural Markdown skill file into the **Hybrid-3** format: a TypeScript Interface layer, a TypeSpec-flavor Operation layer, and a Policy/Invariant layer. The output is immediately executable as a Copilot skill.

## Interface

```typescript
/**
 * @skill transform-legacy-skill
 * @input  { source_md: string }
 * @output { spec_skill: string, ref_stubs: File[] }
 */

type SkillAnatomy = {
  description: string;
  workflow: WorkflowStep[];
  models: ModelConfig[];
  errors: ErrorRow[];
  long_prompts: PromptRef[];
};

type WorkflowStep = {
  id: string;
  action: string;
  inputs: string[];
  outputs: string[];
};
type ModelConfig = { role: string; legacy_model: string; purpose: string };
type ErrorRow = { condition: string; behavior: string };
type PromptRef = { placeholder: string; content: string };

type RefFileAnatomy = {
  sections: string[];
  placeholders: string[];
  has_outer_fence: boolean;
  has_imperative: boolean;
  input_context_vars: string[];
};

type MappingRegistry = {
  "claude-opus": "claude-opus-4.6";
  "gpt-4": "gpt-5.3-codex";
  "gemini-pro": "gemini-3-pro-preview";
};

/**
 * @invariants
 * 1. Zero_Verbosity:      imperative sentences ("First, do X") => remove entirely
 * 2. Signature_Integrity: every `op` => typed (input: T) -> U defined
 * 3. Minimal_Token:       natural-language redundancy => symbolic/typespec notation
 * 4. Ref_File_Parity:    every @references stub => valid Hybrid-3 with >=1 op
 * 5. No_Outer_Fence:     reference file templates => no plain-text code fence wrapper
 * 6. All_Placeholders_Declared: {var} in reference => declared in ## Input Context
 * 7. Semantic_Contract_Preserved: transformed output => same observable behavior as legacy
 */
```

## Operations

```typespec
op deconstruct(source_md: string) -> SkillAnatomy {
  // Parse YAML frontmatter; split sections by ## heading into SkillAnatomy fields
  invariant: (no_workflow_section) => abort("No ## Workflow found in source");
}

op upgrade_models(anatomy: SkillAnatomy) -> SkillAnatomy {
  // Apply MappingRegistry to anatomy.models[*].legacy_model
  invariant: (unknown_model) => passthrough("retain original model name as-is");
}

op abstract_operations(anatomy: SkillAnatomy) -> SpecOp[] {
  // Convert each WorkflowStep to a TypeSpec op with typed I/O; strip imperative language
  invariant: (step_has_no_output) => infer_output_type_from_context(step);
}

op synthesize_invariants(anatomy: SkillAnatomy) -> Invariant[] {
  // Map ErrorRow[] to "Condition => Action" logical expressions
  invariant: (empty_error_rows) => skip("emit no invariants block");
}

op externalize_prompts(anatomy: SkillAnatomy) -> { anatomy: SkillAnatomy; stubs: File[] } {
  // Replace inline prompt content longer than 10 lines with @references/filename.md
  // Emit stub files transforming both layers: outer scaffolding and inner prompt content
  invariant: (prompt_under_10_lines) => passthrough("retain inline");
  invariant: (stub_has_placeholders) => extract_to_input_context_section(stub);
  invariant: (stub_wraps_in_plain_fence) => remove_outer_fence(stub);
}

op render(
  anatomy:   SkillAnatomy,
  ops:       SpecOp[],
  invariants: Invariant[],
  stubs:     File[]
) -> string {
  // Assemble final Hybrid-3 output following @references/output-template.md
  invariant: (render_fail) => abort("Could not render output");
  invariant: (stub_contains_imperative_steps) => abort("Reference file not fully converted");
}
```

## Execution

Execute as:

```
deconstruct -> upgrade_models -> [parallel: abstract_operations + synthesize_invariants + externalize_prompts] -> render
```

The three bracketed ops operate on independent fields of `SkillAnatomy` and may run in parallel.

Present the transformed skill inline. For each stub in `stubs`, present content under `### references/{filename}`.

For detailed mapping rules and annotated before/after examples, read [`references/mapping-rules.md`](references/mapping-rules.md).

For the canonical Hybrid-3 output structure and a complete worked example, read [`references/output-template.md`](references/output-template.md).
