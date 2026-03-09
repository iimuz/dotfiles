---
status: DONE
---

# TASK: Copilot Skills の中間ファイルフォルダの分離

## Prompt

@.config/copilot/skills/code-review/SKILL.md や Ref に記載した Copilot 用の workflow skills
において、実行時には copilot session dir の files フォルダに中間ファイルを生成する。
このとき、同一セッション内で複数回同一の workflow skills を実行した場合、 2 回目以降に同一のファイル名を利用し出力に失敗する場合がある。
そこで、 workflow の 1 回の実行ごとに copilot session dir の files フォルダ内にさらにフォルダを作成し、そこに中間ファイルを生成することでバッティングすることを防ぐようにする。
ただし、各 workflow の最終結果はフォルダ内ではなく files フォルダ直下に複数回実行してもバッティングしないように出力することとする。

code-review skill において、現状と変更後で下記のようになることを想定している。
最終結果ファイルは code-review skill の例であり、各 workflow file の最終成果物のファイルを出力して。
出力フォルダおよびファイル名は `YYYYMMDD-HHMMSS-` を prefix として付け、 skill 名をつけることで、どの出力かがわかるようにすることを想定しています。
ただし、この書き方が最適ではない場合、適切な方法を提案して進めて。

- 現状
  - 中間ファイルの出力先: `~/.copilot/session-state/{session_id}/files/`
- 修正後
  - 中間ファイルの出力先: `~/.copilot/session-state/{session_id}/files/YYYYMMDD-HHMMSS-code-reivew/`
  - 最終結果ファイルの出力先: `~/.copilot/session-state/{session_id}/files/YYYYMMDD-HHMMSS-code-reivew-consolidate-review.md`

## Goal

Copilot Skills において中間ファイルのフォルダが分離され同一セッションで複数回の同一 workflow を実行してもファイル名がバッティングせず正常に動作する状態になっていること。

## Ref

- `.github/instructions/skills.instructions.md`
- `.config/copilot/skills/code-review/SKILL.md`
- `.config/copilot/skills/council/SKILL.md`
- `.config/copilot/skills/implementation-plan/SKILL.md`
- `.config/copilot/skills/review-comment-workflow/SKILL.md`
- `.config/copilot/skills/structured-workflow/SKILL.md`
- `.config/copilot/skills/task-coordinator/SKILL.md`

## Steps

- [x] Step 1: Added run directory convention rules to `skills.instructions.md`.
- [x] Step 2: Updated `code-review/SKILL.md` for `run_dir` intermediates and session-root final output.
- [x] Step 3: Updated `council/SKILL.md` for `run_dir` intermediates and session-root final output.
- [x] Step 4: Updated `implementation-plan/SKILL.md` for `run_dir` intermediates and session-root final output.
- [x] Step 5: Updated `review-comment-workflow/SKILL.md` for `run_dir` intermediates and session-root final output.
- [x] Step 6: Updated `structured-workflow/SKILL.md` for `run_dir` intermediates and session-root final output.
- [x] Step 7: Updated `task-coordinator/SKILL.md` by replacing `{run_id}` with timestamp-based convention.
- [x] Step 8: Ran lint and path consistency checks.

## Verify

- `mise run lint` passes.
- Path consistency checks pass for all updated workflow orchestrator skill files.

## Summary

This work consolidated all related run-directory migration and filename simplification plans into one
self-contained record, then finalized it as complete. The workflow orchestrators now follow one
shared convention that isolates intermediate artifacts per run while keeping final outputs at the
session files root with collision-resistant timestamped names.

- Added 4 run directory convention rules to `.github/instructions/skills.instructions.md`.
- Updated 6 workflow orchestrator SKILL files to use `{run_dir}/` for intermediates and
  `{session_dir}/YYYYMMDDHHMMSS-{skill-name}-{descriptor}` for final outputs.
- Removed redundant `{timestamp}` from intermediate file names in `code-review`, `council`,
  `implementation-plan`, and `review-comment-workflow`.
- Replaced `task-coordinator` `{run_id}` usage with the timestamp-based convention.
- Kept `tdd-workflow` unchanged because it has no session file artifacts.
- Confirmed `structured-workflow` and `task-coordinator` already had no timestamp suffixes in
  intermediate names under the new convention.

Verification results: all lint checks pass and all path consistency checks pass.

## Scratchpad

- Decided to standardize all orchestrator skills on one path strategy to prevent same-session
  collisions without changing final output discoverability.
- Used timestamped run directories only for intermediates and timestamped session-root files only
  for final outputs to keep artifact navigation simple.
- Applied filename simplification where timestamp suffixes were redundant for intermediates in
  four skills.
- Excluded `tdd-workflow` from edits because it does not define session file artifacts.
