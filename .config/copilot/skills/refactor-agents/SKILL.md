---
name: refactor-agents
description: This skill should be used when a comprehensive review of AGENTS.md is needed, comparing the entire repository state against current documentation to identify and apply updates.
---

## Goal

Perform a thorough repository analysis and compare findings against AGENTS.md, presenting specific suggested changes for user approval before applying updates.

## When to Use This Skill

- AGENTS.md feels outdated but recent commits don't reveal full scope of drift
- Major refactoring or restructuring has occurred over time
- Need comprehensive verification of all AGENTS.md sections
- User explicitly requests full AGENTS.md validation
- Periodic maintenance to ensure documentation accuracy

## Instructions

### 1. Perform Comprehensive Repository Analysis

Analyze the entire codebase to understand current state:

**Architecture & Structure**

```bash
### Directory structure
tree -L 3 -d --gitignore || find . -maxdepth 3 -type d -not -path '*/.git/*'
```

Use the glob tool to discover key file patterns: `**/*.{json,toml,yaml,yml,md,sh}`

**Commands & Scripts**

- Check package.json, Makefile, mise.toml, pyproject.toml for scripts
- Identify build, test, lint, deployment commands
- Verify command accuracy by dry-running safe commands (e.g., `--help` flags, `--dry-run` where available). Do not execute destructive or deployment commands.

**Code Conventions**

- Identify import/export patterns (grep for common patterns)
- Document naming conventions (file naming, function naming)
- Extract language-specific patterns (Python, TypeScript, Go, etc.)

**Technology Stack**

- Identify frameworks and libraries (check dependency files)
- Determine language versions (check version manager configs)
- Catalog infrastructure tools (Docker, CI/CD configs)

Use the `explore` agent for complex analysis tasks. Make parallel grep/glob calls for efficiency.

### 2. Load and Parse Existing AGENTS.md

First verify AGENTS.md exists. If it does not exist, inform the user and suggest using the `create-agents` skill instead.

Read AGENTS.md and identify all documented sections:

- Project description
- Code style conventions
- Commands (development, build, test, deploy)
- Architecture overview
- Directory structure
- Important notes and warnings

### 3. Compare Findings Against AGENTS.md

For each section, identify discrepancies:

**Architecture Differences**

- Flag new directories not yet documented
- Remove references to deleted directories
- Update outdated directory descriptions

**Command Differences**

- Identify commands that have changed (different flags, renamed scripts)
- Document new commands not yet listed
- Remove deprecated commands still listed

**Convention Differences**

- Track code style patterns that have evolved
- Document new patterns not yet included
- Remove outdated guidance that conflicts with current code

**Technology Differences**

- Track framework version changes
- List added or removed dependencies
- Document infrastructure changes

### 4. Generate Comparison Report

Create a structured report following the format in `references/report-template.md`.

Present all findings before making any changes.

### 5. Interactive Update Process

If the user has already indicated to apply all changes, skip this step and proceed to Step 6.

Otherwise, use the ask_user tool to request which changes to apply:

- Show numbered list of all suggested changes
- Allow user to select specific updates (e.g., "Apply changes 1, 3, 5-7")
- Provide options: "All", "None", "Select specific changes"

### 6. Apply Approved Changes

For each approved update:

- Make precise edits to AGENTS.md using edit tool. If an edit fails, retry with expanded context or apply manually.
- Preserve existing formatting and style
- Maintain concise, imperative-form language
- Keep bullet-point structure

### 7. Verify and Report

After updates:

- Summarize what sections were changed
- Confirm all approved edits were applied
- Note any sections that remain unchanged

## Success Criteria

- Complete repository analysis covers all major aspects (architecture, commands, conventions)
- Comparison report clearly shows current vs. actual state with specific suggestions
- User has opportunity to review and approve changes before application
- Only approved changes are applied to AGENTS.md
- Updated content is accurate, concise, and matches repository reality
- Final report confirms all changes applied successfully
