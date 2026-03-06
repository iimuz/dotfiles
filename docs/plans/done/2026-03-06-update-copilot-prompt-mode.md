---
status: DONE
---

# TASK: Update Copilot Prompt Mode

## Prompt

`.config/copilot/copilot.sh` の `copilot_prompt` コマンドに以下の機能を `structured-workflow` skill の手順で追加して。

- `copilot_prompt` に `--yolo` option を追加し、オプション追加時は `copilot_yolo` の関数を呼び出して設定を引き継ぐようにする。
- `copilot_prompt` に `--auto` option を追加し、オプション追加時は `copilot_auto` の関数を呼び出して設定を引き継ぐようにする。
- `copilot_prompt` に `-i`, `-p` option を追加し、それぞれ以下のような動作とすること。
  - `-i`: copilot を `--interactive` option でプロンプトを渡し呼び出す。これは interactive mode で copilot が起動する。
  - `-p`: copilot を `--prompt` option でプロンプトを渡し呼び出す。これは prompt mode で copilot が起動する。
- `copilot_prompt` で `-p` で起動するときは、 `--no-ask-user` option を追加すること。
- `copilot_prompt` で `--agent` option が指定されない場合、 `--agnet claude-sonnet-4.6` をデフォルトで起動するようにする。
  - user が `--agent` option をつけて `copilot_prompt` を実行した場合は、 option を上書きすること。
- 追加の引数がある場合に copilot command に引数として渡す。
- system instruction prompt に以下を最適な形に変更して追加する。
  - Ref, Steps, Verify, Scratchpad セクションのみ変更可能とすること。
  - 作業の状況に合わせて Steps での進捗管理に合わせて、 Scratchpad に状況の説明を簡潔に追記すること。

## Goal

`copilot_prompt` の実装を修正して、追加引数を受け取ることができるようにする。
デフォルトプロンプトを改善し最適化する。

## Ref

- `.config/copilot/copilot.sh`
- `docs/plans/done/2026-03-06-copilot-prompt-mode.md`

## Steps

- [x] Step 1: Refactor `copilot_prompt` to use manual `while/case/shift` parser supporting
      `--yolo`, `--auto`, `-i`, `-p`, `--model`, `--agent`, `--`, and passthrough extra args.
- [x] Step 2: Add `--yolo` flag delegating to `copilot_yolo` with normalized prompt args.
- [x] Step 3: Add `--auto` flag delegating to `copilot_auto` with normalized prompt args.
- [x] Step 4: Add `-i` mode (`--interactive` + `--autopilot`) and `-p` mode
      (`--prompt` + `--no-ask-user`).
- [x] Step 5: Add `--model` option with default `claude-sonnet-4.6`; user value overrides.
- [x] Step 6: Add `--agent` option with default `orchestrator`; user value overrides;
      value `default` suppresses the flag entirely.
- [x] Step 7: Forward extra args and `--` passthrough to copilot invocation.
- [x] Step 8: Update system instruction to restrict edits to Ref, Steps, Verify, Scratchpad
      and require Scratchpad progress notes.
- [x] Step 9: Run `mise run lint` and `mise run format`; verified 0 errors.
- [x] Step 10: Change default strategy from `direct` to `auto`; remove direct mode and
      `BASE_OPTS` array.
- [x] Step 11: Update `-i` mode: remove `--autopilot`; update `-p` mode: add `--autopilot`.
- [x] Step 12: Rename all uppercase local variables to `lower_snake_case` (e.g. `USAGE` →
      `usage`, `SOURCE_FILE` → drop redundant copy, `PROMPT_TEXT` → `prompt_text`, etc.).
- [x] Step 13: Add `strategy_specified` guard to keep `--yolo`/`--auto` conflict detection
      correct with the new `auto` default.
- [x] Step 14: Run `mise run lint` and `mise run format`; verify 0 errors.

## Verify

- Verify: Run `mise run lint` and `mise run format` and confirm 0 errors.

## Scratchpad

- Description: Agent workspace for Chain of Thought and investigation notes.
- Iteration 1 (commit 7a382ed): Initial implementation of all requested options completed.
  lint/format passed, code review found no Critical/High issues.
- Iteration 2 (done): User requested: default strategy → `auto`, direct mode
  removal, `-i` drops `--autopilot`, `-p` adds `--autopilot`, all local vars →
  `lower_snake_case`. lint/format passed 0 errors.
- Iteration 2 bugfix (commit 1e5ac5f): `$prompt_text` を位置引数として渡していたため
  copilot が "too many arguments" エラーを出した。`--interactive "$prompt_text"` /
  `--prompt "$prompt_text"` としてフラグの値として渡す形式に修正。
- Iteration 2 bugfix2 (commit d66c6ed): zsh では `"${arr[@]+"${arr[@]}"}"`
  (外側に `"`) の形式が空配列時に空文字列を 1 個生成する。外側の `"` を削除して
  `${arr[@]+"${arr[@]}"}` に修正。
