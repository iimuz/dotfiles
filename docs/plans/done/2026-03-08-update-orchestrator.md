---
status: DONE
---

# TASK: Update orchestrator

## Goal

Rewrite the orchestrator agent configuration so it properly delegates investigation and
judgment to subagents instead of using them as data pipes.

## Ref

- `.config/copilot/agents/orchestrator.md`
- `.github/instructions/custom-agents.instructions.md`

## Steps

- [x] Step 1: Fix delegation model (restrict explore to routing-only, add anti-patterns for
      data-fetch-then-judge, add decision-authority requirement to delegation template)
- [x] Step 2: Remove redundancy (deduplicate Overview vs Process, remove redundant skill
      anti-pattern and skill-integration bullet, fold error handling into process)
- [x] Step 3: Improve clarity (replace "synthesize" with "compile", replace vague validation
      rule with concrete condition, unify tool naming to "agent")
- [x] Step 4: Apply user-requested refinements (error handling as cross-cutting fallback note,
      mandatory model on dispatch, advice anti-pattern rewording)
- [x] Step 5: Verify with lint/format and commit

## Verify

- Verify: Run `mise run lint` and `mise run format` with 0 errors.

## Summary

The orchestrator agent was observed using explore and task subagents as data-fetching pipes,
then performing analysis and judgment on the returned data itself. For example, it would
dispatch an explore agent to run git status and return raw output, then decide next steps from
that output; or it would ask explore to count occurrences of a pattern, then form its own
recommendation from the counts. This violated the orchestrator's core principle: delegate ALL
investigation and decision-making to subagents so the main agent's context stays minimal.

Three categories of changes were applied to `.config/copilot/agents/orchestrator.md`. First,
delegation clarity: the Agent Selection table was narrowed so explore is restricted to simple
factual lookups for routing decisions only, two anti-pattern rules were added prohibiting
data-fetch-then-judge patterns, and the delegation template now requires every dispatch to
include decision authority. Second, redundancy removal: Overview was trimmed to principles only
(procedural content moved to Process), redundant rules in Anti-Patterns and Skill Integration
were removed, and Error Handling was folded into the process flow. Third, new safeguards from
user feedback: error handling was reframed as a cross-cutting fallback note, model specification
was made mandatory on every dispatch, and the advice anti-pattern was reworded for precision.

Key decisions: explore agents are restricted to routing (never for data gathering the
orchestrator will analyze); the word "compile" replaces "synthesize" to better describe result
assembly; model must always be specified on dispatch to prevent default-model drift; tool naming
was unified to "agent" per custom-agents.instructions.md. Code review caught one conflict
between a Process step and an Anti-Pattern rule, resolved by narrowing the Anti-Pattern wording.
Final lint: 0 errors.

## Scratchpad
