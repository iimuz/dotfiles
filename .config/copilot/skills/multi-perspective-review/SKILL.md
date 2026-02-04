---
name: multi-perspective-review
description: Review code changes using multiple AI models in parallel to provide comprehensive feedback from diverse perspectives. Works with PRs, uncommitted changes, and local commits. This skill should be used when thorough multi-perspective code analysis is needed.
---

# Code Review Skill

## Purpose

This skill provides comprehensive code reviews by leveraging multiple AI models in parallel. It orchestrates three general-purpose agents (using different models) to analyze code changes from different perspectives, then synthesizes their feedback into a unified review report.

Use this skill when:

- Conducting thorough code reviews requiring multiple perspectives
- Reviewing PRs, uncommitted changes, or local commits
- Seeking diverse insights on code quality, security, and best practices
- Needing consolidated review output from multiple AI models

## Contract

- Reviews code changes in the current directory (must be a git repository)
- Works with PRs (checked out), uncommitted changes, or local commits
- Never modifies code (review only)
- Uses aspect-based parallel review (4 aspects × 3 models = 12 parallel agents)
- Outputs all review results to session folder files/ directory
- Produces aspect-specific reviews + cross-checks + one consolidated review document

## Workflow

1. **Identify Changes**: Determine what to review in the current directory
   - PR changes (if PR is checked out)
   - Uncommitted changes (staged or unstaged)
   - Local commits not yet pushed
   - The current working directory must be a git repository

2. **Parallel Review**: Launch aspect-based reviews simultaneously
   - 4 review aspects: Security, Quality, Performance, Best Practices
   - For each aspect, launch 3 agents with different AI models (12 agents total)
   - All agents analyze the same changes in parallel
   - Each agent outputs to: `<session-folder>/files/<aspect>-<model-name>-review.md`
   - For large changes, may chunk code and multiply agent count accordingly

3. **Cross-Check Review**: Verify coverage of all review perspectives
   - Identify issues flagged by some agents but not others
   - Re-check specific issues with agents that didn't flag them
   - Output cross-check results to separate files in session folder files/ directory

4. **Consolidate Results**: Synthesize all reviews into unified report
   - Launch integration agent to merge findings from initial reviews and cross-checks
   - Deduplicate overlapping issues
   - Validate findings and flag potential false positives
   - Output consolidated review to session folder files/ directory

## Parallel Review Execution

Launch aspect-based reviews with multiple AI models in parallel.

**Review Aspects:**

Execute reviews across 4 independent aspects (from [references/review-criteria.md](references/review-criteria.md)):

1. **Security Checks (CRITICAL)** - Security vulnerabilities and risks
2. **Code Quality (HIGH)** - Maintainability and coding practices
3. **Performance (MEDIUM)** - Efficiency and optimization
4. **Best Practices (MEDIUM)** - Standards and conventions

**Model Selection:**

For each aspect, use these three models:

- `claude-sonnet-4.5` - Balanced analysis
- `gemini-3-pro-preview` - Alternative perspective
- `gpt-5.2-codex` - Code-focused insights with extended thinking (xhigh)

**Prompt Construction:**

1. Read the template from [references/review-prompt.md](references/review-prompt.md)
2. Read the specific aspect criteria from [references/review-criteria.md](references/review-criteria.md)
3. Replace `[INSERT SPECIFIC ASPECT FROM review-criteria.md HERE]` in the template with the chosen aspect
4. If code changes are large, optionally specify code scope in `[OPTIONAL: If code is chunked for large changes]` section

**Execution Pattern:**

Execute all 12 agents (4 aspects × 3 models) in parallel within a single response:

```
# Security aspect (3 models)
task(agent_type="general-purpose", model="claude-sonnet-4.5", description="Security review - Claude", prompt="<template + Security Checks criteria>")
task(agent_type="general-purpose", model="gemini-3-pro-preview", description="Security review - Gemini", prompt="<template + Security Checks criteria>")
task(agent_type="general-purpose", model="gpt-5.2-codex", description="Security review - GPT", prompt="<template + Security Checks criteria>", thinking_level="xhigh")

# Code Quality aspect (3 models)
task(agent_type="general-purpose", model="claude-sonnet-4.5", description="Quality review - Claude", prompt="<template + Code Quality criteria>")
task(agent_type="general-purpose", model="gemini-3-pro-preview", description="Quality review - Gemini", prompt="<template + Code Quality criteria>")
task(agent_type="general-purpose", model="gpt-5.2-codex", description="Quality review - GPT", prompt="<template + Code Quality criteria>", thinking_level="xhigh")

# Performance aspect (3 models)
task(agent_type="general-purpose", model="claude-sonnet-4.5", description="Performance review - Claude", prompt="<template + Performance criteria>")
task(agent_type="general-purpose", model="gemini-3-pro-preview", description="Performance review - Gemini", prompt="<template + Performance criteria>")
task(agent_type="general-purpose", model="gpt-5.2-codex", description="Performance review - GPT", prompt="<template + Performance criteria>", thinking_level="xhigh")

# Best Practices aspect (3 models)
task(agent_type="general-purpose", model="claude-sonnet-4.5", description="Best Practices review - Claude", prompt="<template + Best Practices criteria>")
task(agent_type="general-purpose", model="gemini-3-pro-preview", description="Best Practices review - Gemini", prompt="<template + Best Practices criteria>")
task(agent_type="general-purpose", model="gpt-5.2-codex", description="Best Practices review - GPT", prompt="<template + Best Practices criteria>", thinking_level="xhigh")
```

**Output Files:**

Each agent saves to: `<session-folder>/files/<aspect>-<model-name>-review.md`

Examples:
- `security-claude-sonnet-4.5-review.md`
- `quality-gemini-3-pro-preview-review.md`
- `performance-gpt-5.2-codex-review.md`

**Code Chunking (for large changes):**

When changes are extensive (>1000 lines or >20 files):

1. Divide code into logical chunks (by directory, module, or feature)
2. For each chunk, execute the full aspect-based review (4 aspects × 3 models)
3. Multiply agent count: (chunks × aspects × models)
4. Update output filenames: `<chunk-name>-<aspect>-<model-name>-review.md`

Example with 2 chunks:
- `frontend-security-claude-sonnet-4.5-review.md`
- `backend-security-claude-sonnet-4.5-review.md`
- etc.

## Cross-Check Review

After aspect-based reviews complete, identify gaps within each aspect and perform targeted re-checks in parallel.

**Cross-Check Process:**

1. **Analyze Initial Reviews**: Compare findings within each aspect across models
   - Read all `<aspect>-*-review.md` files from session folder files/ directory
   - For each aspect, identify issues flagged by some models but not others
   - Create mapping: which model missed which specific concerns within each aspect

2. **Parallel Targeted Re-Check**: Launch all cross-checks simultaneously
   - For each (aspect, model) pair where the model missed issues, prepare targeted cross-check prompt
   - Include only specific concerns that specific model missed in that specific aspect
   - Execute all cross-checks in parallel (not sequentially)
   - Each saves to: `<session-folder>/files/<aspect>-<model-name>-crosscheck.md`

3. **Cross-Check Prompt Template**:

   Use the template from [references/cross-check-prompt.md](references/cross-check-prompt.md).
   
   Key elements:
   - Specify the aspect being cross-checked
   - Provide specific issues/patterns to verify (unique per aspect and model)
   - Ask agent to confirm or refute the concerns
   - Focus on targeted analysis, not full re-review

**Execution Pattern:**

Call all cross-check agents in parallel within a single response:

```
# Example: Within Security aspect, Claude missed issue A, Gemini missed B
# Example: Within Quality aspect, GPT missed issue C
task(agent_type="general-purpose", model="claude-sonnet-4.5", description="Cross-check Security - Claude", prompt="<cross-check-prompt.md for Security with concern A>")
task(agent_type="general-purpose", model="gemini-3-pro-preview", description="Cross-check Security - Gemini", prompt="<cross-check-prompt.md for Security with concern B>")
task(agent_type="general-purpose", model="gpt-5.2-codex", description="Cross-check Quality - GPT", prompt="<cross-check-prompt.md for Quality with concern C>", thinking_level="xhigh")
```

**Guidelines:**

- Execute all cross-checks in parallel, not sequentially
- Cross-check within aspects (compare models within same aspect)
- Only cross-check (aspect, model) pairs that actually missed issues
- Focus on specific issues per aspect and model
- Use same model and configuration (including thinking_level for GPT) as initial review
- Output filenames include aspect: `<aspect>-<model-name>-crosscheck.md`
- If no gaps found in any aspect, skip cross-check phase entirely

## Review Consolidation

After parallel reviews and cross-checks complete, consolidate all findings into a unified report.

**Consolidation Process:**

1. **Launch Integration Agent**: Use general-purpose agent to synthesize results
   - Do not read individual reviews directly
   - Delegate synthesis to agent with access to all review files

2. **Integration Agent Prompt**:

   Use the template from [references/integration-prompt.md](references/integration-prompt.md).
   
   Key tasks:
   - Read all `<aspect>-*-review.md` and `<aspect>-*-crosscheck.md` files from session folder files/ directory
   - Merge duplicate findings from initial reviews and cross-checks across aspects
   - Validate findings against actual code
   - Mark potentially incorrect findings
   - Consider cross-check assessments (VALID/INVALID/UNCERTAIN) when consolidating
   - Output to: `<session-folder>/files/consolidated-review.md`

3. **Output Structure**: Consolidated review should include:
   - Executive summary with statistics
   - Critical issues (grouped and deduplicated)
   - Warnings and suggestions
   - Validation notes for questionable findings

## Rules and Guidelines

**Execution Rules:**

- Always launch exactly three general-purpose agents in parallel
- Each agent must use a different model from the specified list
- All agents must target the current working directory
- Never read or analyze code directly - delegate to agents
- Include full review checklist in each agent's prompt

**Output Requirements:**

- Individual reviews: `<session-folder>/files/<model-name>-review.md`
- Consolidated review: `<session-folder>/files/consolidated-review.md`
- All files must be in session folder files/ directory (not committed to repo)

**Review Quality:**

- Focus on substantive issues (bugs, security, logic errors)
- Validate findings before including in final report
- Preserve false positives but clearly mark them
- Provide actionable recommendations
