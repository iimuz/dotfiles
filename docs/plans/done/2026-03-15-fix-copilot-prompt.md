---
status: DONE
---

# TASK: Fix copilot prompt command

## Prompt

@.config/copilot/copilot.sh において、 `copilot_prompt` を実行時に以下の問題が発生しています。
修正計画を /implementation-plan で作成して。

- 指定した file から抽出した `## Prompt` section が copilot の prompt として設定されている。
- `copilot_prompt` の実行時にデフォルトの agent が orchestrator となっているが、オプション設定がなければ default agent で起動するようになっていること。

## Goal

`copilot_prompt` の実行時に以下が達成できていること。

- file から抽出した `## Prompt` section が copilot の prompt としては削除されていること。
- `copilot_prompt` の実行時にデフォルトは default agent となっていること。

## Ref

- `.config/copilot/copilot.sh`

## Steps

- [x] Step 1: Update this plan file status to `IN_PROGRESS` and confirm steps are populated.
- [x] Step 2: Change `local agent="orchestrator"` to `local agent="default"` in `copilot_prompt` (currently line 66).
- [x] Step 3: Pipe `rg` output through `tail -n +2` on the prompt extraction line
      to strip the `## Prompt` header.
- [x] Step 4: Run `mise run format` to apply formatting.
- [x] Step 5: Run `bash -n .config/copilot/copilot.sh` to verify syntax.
- [x] Step 6: Run `mise run lint` to verify shellcheck compliance.
- [x] Step 7: Run targeted behavioral validation (prompt excludes header,
      no `--agent` by default, explicit `--agent` passes through).
- [x] Step 8: Update this plan file with verification results and completion summary.

## Verify

- `bash -n .config/copilot/copilot.sh` exits 0.
- `mise run lint` exits 0.
- `mise run format` exits 0.
- Extracted prompt text does not contain `## Prompt` header.
- Running without `--agent` does not pass `--agent` flag to copilot.

## Scratchpad
