---
status: TODO
---

# TASK: plans の積極利用

## Prompt

@.github/instructions/plan.instructions.md と @.github/copilot-instructions.md に Copilot が作業実施時には plans ファイルを必ず利用し作業状況が自動でまとめられ更新されるようにして。
plans ファイルは、 template のファイルを利用することは変わらないです。
ただし、事前に作成されたファイルが指定された場合は指定されたファイルを利用し、 plans ファイルが指定されなかった場合は Copilot が作成し更新するようにして。
任意ではなく必ず plans に状況を残すようにして。

## Goal

Copilot が自動で plans を積極的に利用し状況を追跡できるように残せる状態となっていること。

## Ref

- `docs/context.md`
- `src/target_file.ts`

## Steps

- [ ] Step 1: ...
- [ ] Step 2: ...
- [x] Step 8: Simplify copilot-instructions.md Plan step; add ## Lifecycle section to plan.instructions.md
- [x] Step 9: Remove redundant path-check and NEVER-guard from Plan step; simplify wording
- [x] Step 10: Apply council Q1-Q4 recommendations to plan.instructions.md

## Verify

- Verify: Run `npm test` AND ensure coverage > 80%.

## Scratchpad

- Description: Agent workspace for Chain of Thought and investigation notes.
- Step 8 complete: Workflow simplified to single Plan step; plan.instructions.md now owns lifecycle tracking rules.
- Step 9 complete: Plan step now reads "Determine minimal changes" + ALWAYS create rule
  only; redundant NEVER and path-map lines removed.
- Step 10 complete: Optional sections allowed between Verify and Scratchpad;
  Lifecycle updated with On Done and On Finalize; Naming Convention simplified;
  Content Rules adds LOG and SUMMARY definitions.
