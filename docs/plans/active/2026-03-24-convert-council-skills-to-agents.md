---
status: IN_PROGRESS
---

# TASK: Convert Council Sub-Skills to Custom Agents

## Goal

- Goal: Convert all 6 council sub-skills from skills to custom agents,
  embedding references/output-format.md into agent bodies.

## Ref

- `.config/copilot/skills/council/SKILL.md`
- `.config/copilot/skills/council-respond/SKILL.md`
- `.config/copilot/skills/council-anonymize/SKILL.md`
- `.config/copilot/skills/council-review/SKILL.md`
- `.config/copilot/skills/council-aggregate/SKILL.md`
- `.config/copilot/skills/council-synthesize/SKILL.md`
- `.config/copilot/skills/council-fallback/SKILL.md`

## Steps

- [ ] Step 1: Create 6 custom agent files in `.config/copilot/agents/`
      with transformed frontmatter, persona body, and embedded output format.
- [ ] Step 2: Update council orchestrator SKILL.md to use
      `task(agent-name, model=X)` instead of
      `task(general-purpose, model=X) > skill(...)`.
- [ ] Step 3: Delete old skill directories for the 6 converted sub-skills.
- [ ] Step 4: Run `mise run lint` and `mise run format` to verify.

## Verify

- Verify: `mise run lint && mise run format` pass with no errors.

## Scratchpad

- Same pattern as code-review conversion (df71352).
- Frontmatter: user-invocable false, disable-model-invocation true, tools read+search.
- 5 of 6 sub-skills have references/output-format.md to embed (council-respond has none).
