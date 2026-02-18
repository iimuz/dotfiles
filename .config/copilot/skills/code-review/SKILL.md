---
name: code-review
description: Review code changes using multiple AI models in parallel to provide comprehensive feedback from diverse perspectives. Works with PRs, uncommitted changes, and local commits. This skill should be used when thorough multi-perspective code analysis is needed.
---

# Code Review

## Overview

This skill provides comprehensive code reviews by leveraging multiple AI models in parallel across 4 review aspects, followed by targeted cross-checks and consolidation into a single report.

4-stage workflow:

1. **Stage 1 - Parallel Aspect Review**: 12 agents (4 aspects × 3 models) independently analyze the same code changes simultaneously.
2. **Stage 2 - Targeted Cross-Check**: Gaps identified within each aspect are re-verified by the models that missed them (skip if no gaps).
3. **Stage 3 - Consolidate Findings**: An integration agent merges, deduplicates, and validates all findings.
4. **Stage 4 - Deliver Results**: Present the consolidated review to the user.

Use this skill when:

- Conducting thorough code reviews requiring multiple perspectives
- Reviewing PRs, uncommitted changes, or local commits
- Seeking diverse insights on code quality, security, and best practices
- Needing consolidated review output from multiple AI models

Produces: aspect-specific reviews, optional targeted cross-checks, and one consolidated review document — all saved to `~/.copilot/session-state/{session-id}/files/`.

## Reviewer Configuration

| Role | Model | Provider | Focus |
|------|-------|----------|-------|
| Reviewer A | `claude-opus-4.6` | Anthropic | Balanced analysis across all aspects |
| Reviewer B | `gemini-3-pro-preview` | Google | Alternative perspective and pattern recognition |
| Reviewer C | `gpt-5.3-codex` | OpenAI | Code-focused insights (extended thinking: xhigh) |
| Integrator | `general-purpose` agent | — | Synthesis, deduplication, and validation |

Each reviewer operates on all 4 aspects simultaneously. The integrator runs once after all aspect reviews and cross-checks complete.

## Workflow

### Stage 1: Parallel Aspect Review

1. **Determine the review scope** in the current git repository:
   - PR changes (if a PR branch is checked out)
   - Uncommitted changes (staged or unstaged)
   - Local commits not yet pushed to remote

2. **Construct review prompts** for each aspect:
   - Read the template from [references/review-prompt.md](references/review-prompt.md)
   - Read the specific aspect criteria from [references/review-criteria.md](references/review-criteria.md)
   - Replace `[INSERT SPECIFIC ASPECT FROM review-criteria.md HERE]` in the template with the chosen aspect
   - If code is chunked for large changes, fill the optional scope section accordingly

3. **Launch all 12 agents in parallel** (4 aspects × 3 models) within a single response:

```
# Security aspect (3 models)
task(agent_type="general-purpose", model="claude-opus-4.6", description="Security review - Claude", prompt="<template + Security Checks criteria>")
task(agent_type="general-purpose", model="gemini-3-pro-preview", description="Security review - Gemini", prompt="<template + Security Checks criteria>")
task(agent_type="general-purpose", model="gpt-5.3-codex", description="Security review - GPT", prompt="<template + Security Checks criteria>", thinking_level="xhigh")

# Code Quality aspect (3 models)
task(agent_type="general-purpose", model="claude-opus-4.6", description="Quality review - Claude", prompt="<template + Code Quality criteria>")
task(agent_type="general-purpose", model="gemini-3-pro-preview", description="Quality review - Gemini", prompt="<template + Code Quality criteria>")
task(agent_type="general-purpose", model="gpt-5.3-codex", description="Quality review - GPT", prompt="<template + Code Quality criteria>", thinking_level="xhigh")

# Performance aspect (3 models)
task(agent_type="general-purpose", model="claude-opus-4.6", description="Performance review - Claude", prompt="<template + Performance criteria>")
task(agent_type="general-purpose", model="gemini-3-pro-preview", description="Performance review - Gemini", prompt="<template + Performance criteria>")
task(agent_type="general-purpose", model="gpt-5.3-codex", description="Performance review - GPT", prompt="<template + Performance criteria>", thinking_level="xhigh")

# Best Practices aspect (3 models)
task(agent_type="general-purpose", model="claude-opus-4.6", description="Best Practices review - Claude", prompt="<template + Best Practices criteria>")
task(agent_type="general-purpose", model="gemini-3-pro-preview", description="Best Practices review - Gemini", prompt="<template + Best Practices criteria>")
task(agent_type="general-purpose", model="gpt-5.3-codex", description="Best Practices review - GPT", prompt="<template + Best Practices criteria>", thinking_level="xhigh")
```

**Review aspects** (full criteria in [references/review-criteria.md](references/review-criteria.md)):

1. **Security Checks (CRITICAL)** - Security vulnerabilities and risks
2. **Code Quality (HIGH)** - Maintainability and coding practices
3. **Performance (MEDIUM)** - Efficiency and optimization
4. **Best Practices (MEDIUM)** - Standards and conventions

**Code chunking for large changes** (>1000 lines or >20 files):

1. Divide code into logical chunks by directory, module, or feature
2. For each chunk, execute the full 4 aspects × 3 models review
3. Update output filenames: `{chunk}-{aspect}-{model}-review.md`

### Stage 2: Targeted Cross-Check

After Stage 1 completes, identify per-aspect gaps and re-verify in parallel. Skip this stage entirely if no gaps are found.

1. **Analyze initial reviews** within each aspect:
   - Read all `{aspect}-*-review.md` files from `~/.copilot/session-state/{session-id}/files/`
   - For each aspect, identify issues flagged by some models but not others
   - Build a mapping of (aspect, model) pairs that missed specific concerns

2. **Launch targeted re-checks in parallel** — one per (aspect, model) pair with gaps:
   - Use [references/cross-check-prompt.md](references/cross-check-prompt.md) as the prompt template
   - Include only the specific concerns that model missed in that aspect
   - Use the same model and `thinking_level` configuration as Stage 1

```
# Example: Claude missed issue A in Security; GPT missed issue C in Quality
task(agent_type="general-purpose", model="claude-opus-4.6", description="Cross-check Security - Claude", prompt="<cross-check-prompt for Security, concern A>")
task(agent_type="general-purpose", model="gpt-5.3-codex", description="Cross-check Quality - GPT", prompt="<cross-check-prompt for Quality, concern C>", thinking_level="xhigh")
```

**Cross-check execution rules:**

| Rule | Requirement |
|------|-------------|
| Parallelism | Execute all cross-checks in a single parallel response, never sequentially |
| Aspect scope | Cross-check only within the same aspect (compare models on the same aspect) |
| Selectivity | Only launch cross-checks for (aspect, model) pairs that actually missed issues |
| Model parity | Use the same model and thinking_level as the Stage 1 run for that aspect |

### Stage 3: Consolidate Findings

1. **Launch one integration agent** using [references/integration-prompt.md](references/integration-prompt.md):
   - Read all `{aspect}-{model}-review.md` and `{aspect}-{model}-crosscheck.md` files
   - Merge duplicate findings, validate against actual code, flag false positives
   - Consider cross-check assessments (VALID/INVALID/UNCERTAIN) when merging
   - Output to: `~/.copilot/session-state/{session-id}/files/consolidated-review.md`

2. **Consolidated output structure** must include:
   - Executive summary with issue counts by severity
   - Critical issues (grouped and deduplicated)
   - Warnings and suggestions
   - Validation notes for uncertain findings

### Stage 4: Deliver Results

Present the consolidated review to the user using the Output Format below. Do not read individual review files directly — point the user to `consolidated-review.md` or summarize the integration agent's output.

## Output Format

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
*Reviewed by: claude-opus-4.6, gemini-3-pro-preview, gpt-5.3-codex*
*Session files: ~/.copilot/session-state/{session-id}/files/*
```

**Quality standards for all findings:**

| Check | Standard |
|-------|----------|
| File reference | Every critical issue must include file path and line number |
| Confidence label | Uncertain findings must be tagged High/Medium/Low confidence |
| False positives | Preserve in report but mark clearly as unverified |
| Scope | Focus on bugs, security, and logic errors; exclude style-only comments |

## Error Handling

| Condition | Behavior |
|-----------|----------|
| Not a git repository | Abort: "Current directory is not a git repository." |
| No changes detected | Abort: "No reviewable changes found. Stage changes, create commits, or check out a PR branch." |
| Fewer than 2 model responses in Stage 1 | Abort: insufficient review coverage. |
| Exactly 2 of 3 models respond | Continue in degraded mode; note missing model in consolidated report. |
| Model timeout or API failure | Log failure; continue if at least 2 models succeed. |
| Diff exceeds context limit (>1000 lines / >20 files) | Chunk by directory or module; multiply agent count accordingly. |
| Missing prompt template reference file | Abort with message identifying the missing file path. |
| No gaps found in Stage 2 analysis | Skip Stage 2 entirely; proceed directly to Stage 3. |
| Stage 3 integration agent failure | Present the highest-priority findings from individual reviews with a note that consolidation failed. |

## Session Files

All files are saved to `~/.copilot/session-state/{session-id}/files/`:

| File | Content |
|------|---------|
| `{aspect}-claude-opus-4.6-review.md` | Claude's review for that aspect |
| `{aspect}-gemini-3-pro-preview-review.md` | Gemini's review for that aspect |
| `{aspect}-gpt-5.3-codex-review.md` | GPT's review for that aspect |
| `{aspect}-{model}-crosscheck.md` | Targeted cross-check output (Stage 2, when applicable) |
| `consolidated-review.md` | Final integrated review report |

`{aspect}` is one of: `security`, `quality`, `performance`, `best-practices`.

For chunked reviews, prefix with chunk name: `{chunk}-{aspect}-{model}-review.md`.

Example filenames:
- `security-claude-opus-4.6-review.md`
- `quality-gpt-5.3-codex-crosscheck.md`
- `consolidated-review.md`

## Invocation Example

```
# Step 1: invoke the skill
skill: code-review

# Step 2: review begins automatically — no additional input needed
# The skill detects PR changes, staged/unstaged changes, or local unpushed commits
```

Example scenarios well-suited for this skill:
- "Review my latest commits before I push"
- "Review this PR I've checked out"
- "Do a thorough review of my staged changes"
