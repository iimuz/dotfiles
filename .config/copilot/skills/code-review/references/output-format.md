# Output Format

## Delivery Template

```markdown
## Code Review Summary

Brief assessment of overall change quality and scope.

### Critical Issues (Blocking)

- **[file:line]** Description. Why it matters. Suggested fix.

### Improvements (Non-Blocking)

- **[file:line]** Description. Rationale.

### Positive Observations

- Notable good patterns worth highlighting.

---

_Reviewed by: claude-opus-4.6, gemini-3-pro-preview, gpt-5.3-codex_
_Session files: ~/.copilot/session-state/{session-id}/files/_
```

## Quality Standards

| Check            | Standard                                                               |
| ---------------- | ---------------------------------------------------------------------- |
| File reference   | Every critical issue must include file path and line number            |
| Confidence label | Uncertain findings must be tagged High/Medium/Low confidence           |
| False positives  | Preserve in report but mark clearly as unverified                      |
| Scope            | Focus on bugs, security, and logic errors; exclude style-only comments |

## Session Files

All files are saved to `~/.copilot/session-state/{session-id}/files/`:

| File                                      | Content                                                         |
| ----------------------------------------- | --------------------------------------------------------------- |
| `{aspect}-claude-opus-4.6-review.md`      | Claude's review for that aspect                                 |
| `{aspect}-gemini-3-pro-preview-review.md` | Gemini's review for that aspect                                 |
| `{aspect}-gpt-5.3-codex-review.md`        | GPT's review for that aspect                                    |
| `gap-list.md`                             | Stage 2a gap analysis results (routing file read by main agent) |
| `{aspect}-{model}-crosscheck.md`          | Targeted cross-check output (Stage 2b, when applicable)         |
| `consolidated-review.md`                  | Final integrated review report                                  |

`{aspect}` is one of: `security`, `quality`, `performance`, `best-practices`, `design-compliance`.

For chunked reviews, prefix with chunk name: `{chunk}-{aspect}-{model}-review.md`.
