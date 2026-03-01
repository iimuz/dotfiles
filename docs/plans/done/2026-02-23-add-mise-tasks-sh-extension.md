---
status: DONE
---

# TASK: Add .sh extension to mise task scripts

## Goal

- Goal: Rename `.mise/tasks/format` → `.mise/tasks/format.sh` and `.mise/tasks/lint` →
  `.mise/tasks/lint.sh` using `git mv` so they are included in `git ls-files '*.sh'` globs.

## Ref

- `.github/instructions/plan.instructions.md`
- `.mise/tasks/format.sh`
- `.mise/tasks/lint.sh`
- `lefthook.yml`
- `.github/workflows/ci.yml`
- `mise.toml`

## Steps

- [x] Step 1: Search for hardcoded references to `.mise/tasks/format` and `.mise/tasks/lint`
      outside plan artifacts to confirm no caller path updates are required.
- [x] Step 2: Run `git mv .mise/tasks/format .mise/tasks/format.sh`.
- [x] Step 3: Run `git mv .mise/tasks/lint .mise/tasks/lint.sh`.
- [x] Step 4: Verify both renamed scripts remain executable with `ls -la .mise/tasks/*.sh`.
- [x] Step 5: Verify rename-only tracking with `git --no-pager diff --name-status` showing `R` entries for both files.
- [x] Step 6: Verify shell script discovery includes both renamed files with
      `git ls-files '*.sh' | grep '^.mise/tasks/'`.
- [x] Step 7: Verify `mise tasks` still lists task names `format` and `lint`.
- [x] Step 8: Run `mise run format` and confirm success.
- [x] Step 9: Run `mise run lint` and confirm success.
- [x] Step 10: Check `git status` after formatting/linting to confirm the renamed task scripts are now self-targeted.
- [x] Step 11: If newly surfaced findings block checks, apply only minimal fixes required for
      `mise run format` and `mise run lint` to pass.

## Verify

- Verify: `mise run format && mise run lint && [ "$(git ls-files '*.sh' | grep -c '^.mise/tasks/')" -eq 2 ]`

## Scratchpad

- No caller changes needed in `lefthook.yml` or `.github/workflows/ci.yml` because
  invocation is by task name, not file path.
- After rename, both scripts are included in `git ls-files '*.sh'` globs used by lint/format tasks.
- Self-modification: `format.sh` now formats itself via `shfmt -w`. This is the intended behavior.
  `shfmt -w` uses atomic writes and is idempotent, so no runtime risk.
