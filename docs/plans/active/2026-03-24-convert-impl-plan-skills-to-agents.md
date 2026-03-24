---
status: IN_PROGRESS
---

# TASK: Convert Implementation-Plan Sub-Skills to Custom Agents

## Goal

- Goal: Convert 4 implementation-plan sub-skills to custom agents with
  appropriate tools and embedded references.

## Ref

- `.config/copilot/skills/implementation-plan/SKILL.md`
- `.config/copilot/skills/implementation-plan-draft/SKILL.md`
- `.config/copilot/skills/implementation-plan-review/SKILL.md`
- `.config/copilot/skills/implementation-plan-resolve/SKILL.md`
- `.config/copilot/skills/implementation-plan-synthesize/SKILL.md`

## Steps

- [ ] Step 1: Create 4 custom agent files in `.config/copilot/agents/`
      with persona body, correct tools, and embedded references.
- [ ] Step 2: Update implementation-plan orchestrator SKILL.md to use
      `task(agent-name, model=X)` invocation pattern.
- [ ] Step 3: Delete old skill directories.
- [ ] Step 4: Run `mise run lint` and `mise run format` to verify.

## Verify

- Verify: `mise run lint && mise run format` pass with no errors.

## Scratchpad

- Tools per agent:
  - draft: read, search, edit (codebase exploration + file output)
  - review: read, search, edit (draft verification against codebase)
  - resolve: read, search, edit (conflict resolution with codebase check)
  - synthesize: read, edit (document assembly only)
- Remove "don't check code" restrictions from review.
- Embed plan-template.md into draft agent.
- Embed output-format.md into synthesize agent.
