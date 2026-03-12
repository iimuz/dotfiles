---
status: DONE
---

# TASK: Copilot Prompt command の更新

## Prompt

@.config/copilot/copilot.sh の `copilot_prompt` 関数では、user task と system instructions が分かれています。
user task は、 Prompt としてファイルから読み取り挿入し、 system instructions で user task の prompt を入力した file の構造にそって修正を書いています。
一方で、 system prompt の更新については、
@.github/instructions/plan.instructions.md に記載されており、
他のリポジトリで同様の関数を利用する場合も
plan.instructions のような方法で修正方法を提示します。
そのため、 Copilot が動作するためには不要ではないかという気がしており最適な方法を /council で提案して。
ただし、 prompt 自体を入力したファイルは Copilot に明示する必要があるのでパスは、 prompt_text に含めるようにしたい。

## Goal

`.config/copilot/copilot.sh` において、 `copilot_prompt` command の system instructions のところでファイル形状によらずなっていること。
また、 user task や system instructions の区分けが不要であれば削除して単一のプロンプトとできていること。

## Ref

- `.config/copilot/copilot.sh`
- `.github/instructions/plan.instructions.md`

## Steps

- [x] Step 1: `copilot_prompt` 関数の `prompt_text` 変数を変更。
      `<user_task>` / `<system_instruction>` XML タグを削除し、
      フラットなプロンプトに置換:
      `${prompt_section}\n\nUpdate ${source_file}.`
- [x] Step 2: `mise run lint` と `mise run format` で検証
- [x] Step 3: 動作確認

## Verify

- `mise run lint` が 0 エラー
- `mise run format` が差分なし

## Summary

Council deliberation (2 rounds, 3 models each) determined that `copilot_prompt` の
`<user_task>`/`<system_instruction>` XML 構造と hardcoded plan-editing ルールは冗長かつ有害。
`plan.instructions.md` が `applyTo` パターンで自動ロードされるため、プロンプトにルールを重複記述する必要はない。
フラットプロンプト `${prompt_section}\n\nUpdate ${source_file}.` に簡素化。
lint/format 検証完了、コミット済み (e043568)。

## Scratchpad

- Council Round 1: system instructions の簡素化で全会一致。XML タグ不要、lifecycle ルールは plan.instructions.md に委譲。
- Council Round 2: "Follow the plan lifecycle rules..." 文も不要で全会一致。auto-load で冗長、ないリポジトリで有害。
- 最終テンプレート: `${prompt_section}\n\nUpdate ${source_file}.`
