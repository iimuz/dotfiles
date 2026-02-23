---
status: TODO
---

# TASK: Validate plan template compliance

## GOAL

- Goal: Implement a shell validator that checks `docs/plans/active/*.md` files conform to
  `docs/templates/plan.md` structure, integrated into lefthook pre-commit and `mise run lint`.

## REF

- `docs/templates/plan.md`
- `docs/design/doc-standards.md`
- `lefthook.yml`
- `.mise/tasks/lint`

## STEPS

- [ ] Step 1: Create `.mise/tasks/validate-plan` shell script that checks (a) frontmatter with
      `status:` key, (b) required sections `## GOAL`, `## REF`, `## STEPS`, `## VERIFY`, `## SCRATCHPAD`
      in order, (c) filename matches `[YYYY-MM-DD]-[action].md`.
- [ ] Step 2: Add `validate-plan` to `lefthook.yml` as a pre-commit hook with
      `glob: "docs/plans/active/*.md"`.
- [ ] Step 3: Add `mise run validate-plan` step to `.github/workflows/ci.yml` after
      `mise run lint`.
- [ ] Step 4: Test with a fixture file missing a required section to confirm error message is
      specific (e.g., `missing section: VERIFY`).

## VERIFY

- Verify: Run `mise run validate-plan` on existing plan files with no errors, and on a broken
  fixture file with a clear failure message.

## SCRATCHPAD

- Council synthesis: 4-layer strategy recommended: (1) shell validator, (2) lefthook pre-commit,
  (3) CI, (4) agent instructions. Layer 4 is already done.
- Implementation detail: Use `grep -n '^## '` to get section line numbers, compare positions
  numerically. Use `awk` for frontmatter `---` block detection.
- Error message design: Return `missing section: VERIFY`, `wrong order: STEPS before REF`,
  `missing frontmatter key: status` — not generic `invalid`.
- Defer AST-based (remark/unified) validation until requirements grow beyond what shell handles.
  Current scope is 3 checks only.
- Existing `infrastructure-ci-mise-1.md` does not follow the template. Decide on
  allowlist/migration before enabling strict enforcement.
