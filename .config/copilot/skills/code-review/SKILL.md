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

**Main-agent I/O invariant:** The main agent never reads Stage 1/2 intermediate files (`*-review.md`, `*-crosscheck.md`). Intermediate file reads are delegated to sub-agents. In Stage 4, the main agent reads only `~/.copilot/session-state/{session-id}/files/consolidated-review.md`.

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
| Reviewer C | `gpt-5.3-codex` | OpenAI | Code-focused insights |
| Integrator | `general-purpose` agent | — | Synthesis, deduplication, and validation |

Each reviewer operates on all 4 aspects simultaneously. The integrator runs once after all aspect reviews and cross-checks complete.

## Workflow

### Stage 1: Parallel Aspect Review

1. **Determine the review scope** in the current git repository:
   - PR changes (if a PR branch is checked out)
   - Uncommitted changes (staged or unstaged)
   - Local commits not yet pushed to remote

2. **Prepare delegated reviewer prompts** for each aspect:
   - Do not read template/criteria content in the main agent.
   - Pass each reviewer sub-agent: `skill_root`, `session_id`, assigned aspect header, and optional chunk scope.
   - Instruct each reviewer sub-agent to read `<skill_root>/references/review-prompt.md` and `<skill_root>/references/review-criteria.md` locally.
   - Instruct each reviewer sub-agent to replace `[INSERT SPECIFIC ASPECT FROM review-criteria.md HERE]` with its assigned criteria section before review execution.

3. **Launch all 12 agents in parallel** (4 aspects × 3 models) within a single response:

```
# Prompt pattern used for all 12 reviewer tasks:
# "Use skill_root=<skill_root>. Read <skill_root>/references/review-prompt.md.
#  Read <skill_root>/references/review-criteria.md. Extract <ASPECT_HEADER>.
#  Replace placeholder, run review, and write to ~/.copilot/session-state/{session-id}/files/<aspect>-<model-name>-review.md."

# Security aspect (3 models)
task(agent_type="general-purpose", model="claude-opus-4.6", description="Security review - Claude", prompt="<self-read pattern; ASPECT_HEADER=Security Checks>")
task(agent_type="general-purpose", model="gemini-3-pro-preview", description="Security review - Gemini", prompt="<self-read pattern; ASPECT_HEADER=Security Checks>")
task(agent_type="general-purpose", model="gpt-5.3-codex", description="Security review - GPT", prompt="<self-read pattern; ASPECT_HEADER=Security Checks>")

# Code Quality aspect (3 models)
task(agent_type="general-purpose", model="claude-opus-4.6", description="Quality review - Claude", prompt="<self-read pattern; ASPECT_HEADER=Code Quality>")
task(agent_type="general-purpose", model="gemini-3-pro-preview", description="Quality review - Gemini", prompt="<self-read pattern; ASPECT_HEADER=Code Quality>")
task(agent_type="general-purpose", model="gpt-5.3-codex", description="Quality review - GPT", prompt="<self-read pattern; ASPECT_HEADER=Code Quality>")

# Performance aspect (3 models)
task(agent_type="general-purpose", model="claude-opus-4.6", description="Performance review - Claude", prompt="<self-read pattern; ASPECT_HEADER=Performance>")
task(agent_type="general-purpose", model="gemini-3-pro-preview", description="Performance review - Gemini", prompt="<self-read pattern; ASPECT_HEADER=Performance>")
task(agent_type="general-purpose", model="gpt-5.3-codex", description="Performance review - GPT", prompt="<self-read pattern; ASPECT_HEADER=Performance>")

# Best Practices aspect (3 models)
task(agent_type="general-purpose", model="claude-opus-4.6", description="Best Practices review - Claude", prompt="<self-read pattern; ASPECT_HEADER=Best Practices>")
task(agent_type="general-purpose", model="gemini-3-pro-preview", description="Best Practices review - Gemini", prompt="<self-read pattern; ASPECT_HEADER=Best Practices>")
task(agent_type="general-purpose", model="gpt-5.3-codex", description="Best Practices review - GPT", prompt="<self-read pattern; ASPECT_HEADER=Best Practices>")
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

After Stage 1 completes, launch one cross-check orchestrator sub-agent. The main agent does not read any `*-review.md` files.

1. **Launch one orchestrator task**:

```
task(
  agent_type="general-purpose",
  description="Cross-check orchestrator",
  prompt="Use skill_root=<skill_root> and session_id=<session-id>.
  Read Stage 1 outputs from ~/.copilot/session-state/{session-id}/files/ using both:
  - {aspect}-*-review.md
  - {chunk}-{aspect}-{model}-review.md
  Aspects: security, quality, performance, best-practices.

  Build per-aspect missed-concern mappings, then launch targeted cross-check workers in parallel.
  Each cross-check worker must use the same model that missed the concern in Stage 1 (model parity).
  Each worker must use <skill_root>/references/cross-check-prompt.md and write
  ~/.copilot/session-state/{session-id}/files/{aspect}-{model}-crosscheck.md.

  If no gaps are found, skip fan-out.
  If running in degraded mode, compare available models only.

  Return one summary string only:
  gaps_found: <N>; cross_checks_launched: <N>; cross_checks_completed: <N>; failures: <N>; notes: <short summary>

  Do not return intermediate file content."
)
```

**Cross-check execution constraints:**

| Constraint | Rule |
|------------|------|
| Parallelism | Execute all cross-check workers in a single parallel response |
| Aspect scope | Cross-check only within the same aspect (do not mix aspects) |
| Selectivity | Only launch cross-checks for (aspect, model) pairs that actually missed issues |
| Model parity | Each cross-check worker must use the same model as the Stage 1 run that missed the concern |

2. **Await orchestrator completion** and route to Stage 3 using summary fields only.

### Stage 3: Consolidate Findings

1. **Launch one integration agent** using [references/integration-prompt.md](references/integration-prompt.md):
   - Integration sub-agent (not the main agent) reads all `{aspect}-{model}-review.md` and `{aspect}-{model}-crosscheck.md` files
   - Integration sub-agent merges duplicate findings, validates against actual code, and flags false positives
   - Integration sub-agent considers cross-check assessments (VALID/INVALID/UNCERTAIN) when merging
   - Output to: `~/.copilot/session-state/{session-id}/files/consolidated-review.md`

2. **Consolidated output structure** must include:
   - Executive summary with issue counts by severity
   - Critical issues (grouped and deduplicated)
   - Warnings and suggestions
   - Validation notes for uncertain findings

### Stage 4: Deliver Results

Read only `~/.copilot/session-state/{session-id}/files/consolidated-review.md`, then present the consolidated review to the user using the Output Format below. Do not read Stage 1/2 intermediate files directly.

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
| Missing prompt template reference file | Sub-agent reports missing file path; main agent continues only if coverage remains >=2 models for required comparisons. |
| No gaps found in Stage 2 analysis | Cross-check orchestrator returns `gaps_found: 0`; skip cross-check fan-out and proceed directly to Stage 3. |
| Cross-check orchestrator failure | Log failure, continue to Stage 3 using Stage 1 artifacts only, and note reduced confidence in consolidated output. |
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
