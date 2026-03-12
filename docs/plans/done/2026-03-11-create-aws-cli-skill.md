---
status: DONE
---

# TASK: Create AWS CLI Skill

## Goal

- Goal: Capture the completed AWS CLI skill creation and restructure decisions in one self-contained plan.

## Ref

- `.config/copilot/skills/aws-cli/SKILL.md`
- `.config/copilot/skills/aws-cli-log-retrieval/SKILL.md`
- `.github/instructions/skills.instructions.md`
- `.github/instructions/doc-standards.instructions.md`
- `docs/templates/plan.md`

## Steps

- [x] Step 1: Define the AWS CLI log investigation skill around the original problems of missing
      time bounds, main-agent log retrieval, missing persistence, unstructured investigation flow,
      and missing permission prechecks.
- [x] Step 2: Change the skill from a Knowledge/Transform design to a Workflow skill after user
      feedback required explicit subagent delegation, and move Stage 1 Initialize to the main agent
      because it has minimal context impact.
- [x] Step 3: Create `aws-cli-log-retrieval` as a dedicated sub-skill instead of keeping retrieval
      guidance in a `references/` file, simplify subagent prompts to avoid overlap with sub-skill
      content, and replace project-specific examples with generic placeholders.
- [x] Step 4: Finalize workflow rules by requiring a permissions precheck, a 15-minute query
      limit, mandatory file storage with optional SQL storage, and a single run directory at
      `{run_timestamp}-aws-cli/`.
- [x] Step 5: Apply council review changes, including pagination, `--filter-pattern`,
      `--output json`, a role model fix, and deduplication, then complete the targeted MD013 cleanup
      for `.config/copilot/skills/aws-cli/SKILL.md`.

## Verify

- Verify: Historical verification recorded by the prior plans shows `mise run format` completed
  without changing `.config/copilot/skills/aws-cli/SKILL.md` or
  `.config/copilot/skills/aws-cli-log-retrieval/SKILL.md`, repo-wide `mise run lint` failed only
  because of issues in the now-removed report file, and targeted `markdownlint-cli2` on
  `.config/copilot/skills/aws-cli/SKILL.md` eventually passed with 0 errors after fixing 4 MD013
  violations.

## Summary

The AWS CLI skill work is now captured as one maintainable plan. The original issues were
long-running queries caused by missing time bounds, main-agent log retrieval that consumed
context, repeated queries caused by missing persistence, an unstructured investigation process,
and missing permission prechecks. Those problems were resolved by adopting explicit workflow
orchestration, creating the `aws-cli-log-retrieval` sub-skill, requiring a 15-minute query
limit, consolidating storage into `{run_timestamp}-aws-cli/`, making file storage mandatory with
SQL as an optional analysis aid, simplifying prompts, replacing project-specific content with
generic placeholders, and incorporating council review fixes for pagination, `--filter-pattern`,
`--output json`, the role model fix, and deduplication. Final recorded verification state:
format completed without changing the targeted skill files, repository lint was previously
blocked only by the deleted report file, and targeted markdownlint later passed with 0 errors
after the 4 MD013 fixes.

## Scratchpad

- Skill type changed from Knowledge/Transform to Workflow because the user required explicit
  subagent delegation for retrieval and cross-service timeline work.
- `aws-cli-log-retrieval` was introduced as a sub-skill instead of a `references/` guide so
  retrieval instructions could be invoked directly and kept separate from orchestration.
- Stage 1 Initialize moved to the main agent because the setup work has minimal context impact,
  while heavier retrieval and synthesis remain delegated.
- Subagent prompts were simplified so they focus on task framing and do not duplicate
  `aws-cli-log-retrieval` procedures.
- File storage is mandatory and SQL storage is optional; all run artifacts live under the single
  `{run_timestamp}-aws-cli/` directory.
- A 15-minute query limit was added to prevent long-running CloudWatch Logs requests.
- Generic placeholders replaced project-specific profile, region, and service details.
