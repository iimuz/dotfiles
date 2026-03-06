---
status: DONE
---

# TASK: Add copilot_prompt Wrapper Function

## Goal

- Goal: Add a `copilot_prompt` function to `.config/copilot/copilot.sh` that extracts a
  `## Prompt` section from a markdown file and executes `copilot -p` in non-interactive
  prompt mode with conservative deny-lists.

## Ref

- `.config/copilot/copilot.sh`
- `.config/rc-settings.sh`
- `docs/design/core-beliefs.md`
- `.github/instructions/setup-scripts.instructions.md`
- `.github/instructions/tool-configuration.instructions.md`

## Steps

- [ ] Step 1: Add `copilot_prompt` function skeleton inside the existing `copilot` guard
      block in `.config/copilot/copilot.sh` with argument validation (exit 1 if no argument
      provided).
- [ ] Step 2: Add call-time `rg` availability guard using `type rg >/dev/null 2>&1` inside
      the function body (not at source time) to avoid blocking shell startup when ripgrep is
      absent.
- [ ] Step 3: Add file existence validation using `[ -f "$1" ]` to support both absolute and relative paths.
- [ ] Step 4: Implement `## Prompt` section extraction using EOF-safe regex:
      `rg -U --pcre2 '(?s)^## Prompt\n(.*?)(?=^## |\z)' "$1"` and validate the result is
      non-empty.
- [ ] Step 5: Construct the structured prompt payload wrapping extracted text in
      `<user_task>` tags and appending a hardcoded `<system_instruction>` block directing the
      agent to update the `## Steps` section in the source file.
- [ ] Step 6: Build the `local -ar OPTIONS` array with deny-lists matching `copilot_auto`
      pattern (deny git checkout/push/rebase/reset/switch, npm remove/uninstall, rm -f/-rf,
      sudo) plus `--allow-all-tools`. Omit `--add-dir` flag (YAGNI).
- [ ] Step 7: Invoke `copilot -p "$PROMPT" --autopilot "${OPTIONS[@]}"` to execute in non-interactive prompt mode.
- [ ] Step 8: Run `bash -n .config/copilot/copilot.sh` to validate syntax before heavier checks.
- [ ] Step 9: Run `mise run format` and `mise run lint` to confirm shfmt and shellcheck compliance.
- [ ] Step 10: Run `git --no-pager diff --name-only` to verify only
      `.config/copilot/copilot.sh` was modified (scope audit).

## Verify

- Verify: `bash -n .config/copilot/copilot.sh && mise run lint && mise run format` all
  exit 0, and `git --no-pager diff --name-only` shows only `.config/copilot/copilot.sh`.

## Scratchpad

- Description: Agent workspace for Chain of Thought and investigation notes.
- Synthesis Source: 3 plan drafts (claude-opus-4.6, gemini-3-pro-preview, gpt-5.3-codex),
  3 cross-reviews, consensus, resolutions, validated insights.
- Key Decisions:
  - Function name: `copilot_prompt` (mirrors `copilot_auto` naming pattern).
  - CLI flags: `-p` (prompt mode) and `--autopilot` (continuation for multi-step tasks).
  - Regex: `(?s)^## Prompt\n(.*?)(?=^## |\z)` handles both mid-file and EOF cases.
  - `rg` guard: Call-time, not source-time, to preserve shell startup behavior.
  - `bash -n`: Pre-lint zero-dependency syntax check before shellcheck.
  - `--add-dir`: Omitted per YAGNI; trivial one-line addition if needed later.
  - Security: Conservative deny-list matching `copilot_auto` defaults.
  - Scope: Strictly additive; no changes to `copilot_auto`, `copilot_yolo`, `rc-settings.sh`, or setup scripts.
  - Error cases: 4 explicit failures (missing arg, missing rg, missing file, empty extraction).
  - `"$@"` forwarding: Include to allow user-supplied extra arguments, matching existing wrapper pattern.
  - Japanese comments: Match existing style where appropriate.
