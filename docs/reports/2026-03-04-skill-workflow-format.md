---
date: 2026-03-04
topic: skill-workflow-format
status: done
---

# Skill Workflow Format Report

## Question

- Which Execution/Workflow section format in SKILL.md files is better for
  LLM agent processing: `structured-workflow` style or
  `resolve-comments` style?
- What is the recommended optimal format?

## Council Result

- Participants: claude-opus-4.6, gpt-5.3-codex (gemini-3-pro-preview did not respond)
- Ranking: gpt-5.3-codex proposal ranked 1st unanimously by all 3 reviewers
- Consensus: Neither existing format is optimal; a hybrid 6-field stage template is recommended

## Problem Analysis

### structured-workflow Problems

- File: `.config/copilot/skills/structured-workflow/SKILL.md`
- Stage structure is non-uniform across phases (Phase 1 through Phase 5 use different conventions)
- Inline task() prompts are embedded directly in execution text, inflating context window
- Branch/loop control logic is mixed into stage descriptions
- fault() declarations appear as standalone code blocks rather than per-stage fields
- Naming uses "Phase N" instead of "Stage N" (inconsistent with other skills)
- No explicit Inputs or Outputs fields per stage

### resolve-comments Problems

- File: `.config/copilot/skills/resolve-comments/SKILL.md`
- Workflow stages use prose descriptions that are harder for LLMs to pattern-match
- No explicit Purpose, Inputs, or Outputs fields
- Actions are described in mixed prose and code blocks
- More uniform than structured-workflow but still not machine-optimal

## Recommendation: 6-Field Stage Template

### Template Definition

```text
### Stage N: Name

- Purpose: one-sentence stage objective
- Inputs: list of required inputs with types
- Actions:
  skill(name: "...", input: { ... })
  task(agent_type: "...", model: "...", prompt: "pass file paths, not inline content")
- Outputs: list of output artifacts with paths
- Guards: conditions required to proceed
- Faults:
  fault(<condition>) => fallback: <action>; <continue|abort>
```

### Example: Before (Phase 1 in structured-workflow current format)

```text
### Phase 1: Plan

skill(name: "implementation-plan",
      input: { session_id, user_request: task })

Extract `plan_filepath` from `PlanResult`. Write plan summary for Phase 4:

task(agent_type: "explore", model: "claude-opus-4.6",
     prompt: "Read the plan at {plan_filepath}
              and write a 1-paragraph summary
              ...")

fault(skill_fails) => fallback: none; abort
```

### Example: After (Phase 1 rewritten with 6-field template)

```text
### Stage 1: Plan

- Purpose: generate implementation plan and write plan summary
- Inputs:
  - session_id: string
  - task: string (user request)
- Actions:
  skill(name: "implementation-plan", input: { session_id, user_request: task })
  task(agent_type: "explore", model: "claude-opus-4.6",
       prompt: "read {plan_filepath}, write summary to {session_dir}/plan-summary.md")
- Outputs:
  - plan_filepath: path to generated plan file
  - plan-summary.md: written to session_dir
- Guards: plan_filepath must be non-empty
- Faults:
  fault(skill_fails) => fallback: none; abort
  fault(summary_write_fails) => fallback: none; abort
```

## Migration Steps

- Step 1: rename all "Phase N" headings to "Stage N" in `.config/copilot/skills/structured-workflow/SKILL.md`
- Step 2: for each stage in `structured-workflow/SKILL.md`, add Purpose, Inputs, Outputs, Guards fields
- Step 3: move fault() declarations from standalone code blocks into per-stage Faults fields
- Step 4: extract inline task() prompt text into external reference files under `references/`
- Step 5: apply same 6-field template to `.config/copilot/skills/structured-workflow-implement/SKILL.md`
- Step 6: run `mise run format` and `mise run lint` after changes
- Step 7: verify `git --no-pager diff --name-only` shows only the two target files

## References

- `.github/instructions/skills.instructions.md` - workflow skill authoring rules
- `.config/copilot/skills/resolve-comments/SKILL.md` - reference for uniform stage structure
- `.config/copilot/skills/structured-workflow/SKILL.md` - primary migration target
- `.config/copilot/skills/structured-workflow-implement/SKILL.md` - secondary migration target
