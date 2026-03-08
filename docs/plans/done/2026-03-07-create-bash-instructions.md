---
status: DONE
---

# TASK: Create bash instructions

## Prompt

参考資料を元に @.github/instructions/language-bash.instructions.md に bash script ファイル用の instructions ファイルを作成して。
linter, formatter で検出する内容を書く必要はありません。
/structured-workflow の手順で作成して。

## Goal

GitHub Copilot CLI が利用するときに最適な bash script ファイル用の instructions ファイルを作成すること。

## Ref

- 出力先: @.github/instructions/language-bash.instructions.md
- 参考資料
  - `sickn33/antigravity-awesome-skills`
    - <https://github.com/sickn33/antigravity-awesome-skills/blob/main/skills/bash-pro/SKILL.md>
    - <https://github.com/sickn33/antigravity-awesome-skills/blob/main/skills/bash-linux/SKILL.md>
    - <https://github.com/sickn33/antigravity-awesome-skills/blob/main/skills/bash-scripting/SKILL.md>
    - <https://github.com/sickn33/antigravity-awesome-skills/blob/main/skills/bash-defensive-patterns/SKILL.md>
      - <https://github.com/sickn33/antigravity-awesome-skills/blob/main/skills/bash-defensive-patterns/resources/implementation-playbook.md>
    - <https://github.com/sickn33/antigravity-awesome-skills/blob/main/skills/linux-shell-scripting/SKILL.md>
    - <https://github.com/sickn33/antigravity-awesome-skills/blob/main/skills/error-handling-patterns/SKILL.md>
      - <https://github.com/sickn33/antigravity-awesome-skills/blob/main/skills/error-handling-patterns/resources/implementation-playbook.md>

## Steps

- [x] Step 1: Explored existing `.github/instructions/language-*.instructions.md` files and
      `setup-scripts.instructions.md` as references.
- [x] Step 2: Created `.github/instructions/language-bash.instructions.md` with sections
      Architecture, Error Handling, Security, Naming Conventions, Idioms, and Portability
      (commit `83a6dd30`).
- [x] Step 3: Ran code review and identified one Critical issue (missing secret handling) and
      three High issues (ShellCheck-duplicating rules).
- [x] Step 4: Fixed review findings by adding secret handling rules and replacing three
      linter-duplicate rules with judgment-based rules (commit `86ea22f4`).
- [x] Step 5: Re-ran code review and confirmed no Critical or High findings.
- [x] Step 6: Added a Testing section and replaced "when practical" wording with strong ALWAYS
      imperative language (commit `9d7436d9`).
- [x] Step 7: Moved two Precedence rules to `.config/copilot/copilot-instructions.md`, removed
      `## Precedence` from bash instructions, and removed the BATS-specific testing rule
      (commit `5f2cd35f`).

## Verify

- Verify: `mise run lint` exits 0 AND `mise run format` exits 0 AND
  `.github/instructions/language-bash.instructions.md` exists.

## Scratchpad

None
