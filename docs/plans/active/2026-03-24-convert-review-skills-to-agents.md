---
status: IN_PROGRESS
---

# TASK: Convert Code Review Sub-Skills to Custom Agents

## Goal

- Goal: Convert all 8 code-review sub-skills from skills to custom agents
  for platform-level tool restriction and simpler invocation.

## Ref

- `.config/copilot/skills/code-review/SKILL.md`
- `.config/copilot/skills/code-review-security/SKILL.md`
- `.config/copilot/skills/code-review-quality/SKILL.md`
- `.config/copilot/skills/code-review-performance/SKILL.md`
- `.config/copilot/skills/code-review-best-practices/SKILL.md`
- `.config/copilot/skills/code-review-design-compliance/SKILL.md`
- `.config/copilot/skills/code-review-gap-analysis/SKILL.md`
- `.config/copilot/skills/code-review-cross-check/SKILL.md`
- `.config/copilot/skills/code-review-consolidate/SKILL.md`
- `.config/copilot/agents/orchestrator.md`
- `.github/instructions/skills.instructions.md`

## Steps

- [x] Step 1: Create 8 custom agent files in `.config/copilot/agents/`
      with transformed frontmatter and preserved prompt body.
- [x] Step 2: Update code-review orchestrator SKILL.md to use
      `task(agent-name, model=X)` instead of
      `task(general-purpose, model=X) > skill(...)`.
- [x] Step 3: Update `.github/instructions/skills.instructions.md`
      canonical examples (removed deleted skill references).
- [x] Step 4: Delete old skill directories for the 8 converted sub-skills.
- [ ] Step 5: Run `mise run lint` and `mise run format` to verify.

## Verify

- Verify: `mise run lint && mise run format` pass with no errors.

## Scratchpad

- Council v2 decision: all 8 sub-components as custom agents.
- Frontmatter template: `user-invocable: false`, `disable-model-invocation: true`, `tools: ["read", "search"]`.
- Orchestrator pattern: `task(code-review-{aspect}, model=X)` with parameters in blockquote.
- 20K character threshold for skill reversion monitoring.
