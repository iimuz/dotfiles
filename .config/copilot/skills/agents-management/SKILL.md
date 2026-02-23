---
name: agents-management
description: This skill manages copilot-instructions.md and .instructions.md files that provide repository context for AI agents. This skill should be used when creating, updating, or comprehensively reviewing project documentation for AI agent workflows.
---

# Copilot Instructions Management

Manage copilot-instructions.md and .instructions.md files that help AI agents understand repository
architecture, commands, and conventions.

## When to Use This Skill

Use this skill when:

- Creating copilot-instructions.md for the first time (new repository documentation)
- Updating copilot-instructions.md after recent code changes (incremental maintenance)
- Performing comprehensive review of copilot-instructions.md accuracy (periodic validation)
- User explicitly requests copilot-instructions.md creation, update, or review

## Workflow Selection

This skill handles three distinct workflows based on context:

### 1. Create Workflow (`references/create-workflow.md`)

**Trigger when:**

- `.github/copilot-instructions.md` does not exist in repository
- User explicitly asks to "create" copilot-instructions.md
- Starting fresh documentation for a repository

**Process:** Analyze entire codebase and generate structured documentation from scratch.

### 2. Update Workflow (`references/update-workflow.md`)

**Trigger when:**

- `.github/copilot-instructions.md` exists and needs incremental updates
- User mentions "update", "recent changes", or "after implementing"
- Following feature implementation or code changes
- Default choice when copilot-instructions.md exists and no comprehensive review requested

**Process:** Review recent git history (last 5 commits) and surgically update affected sections.

### 3. Refactor Workflow (`references/refactor-workflow.md`)

**Trigger when:**

- `.github/copilot-instructions.md` exists but comprehensive validation needed
- User mentions "review", "comprehensive", "refactor", or "validate"
- Suspected drift between documentation and codebase
- Periodic maintenance for accuracy verification

**Process:** Perform full repository analysis, compare against copilot-instructions.md, present changes for user approval.

## Instructions

### Step 1: Detect Workflow

Determine which workflow applies based on:

1. **File existence check:** Does `.github/copilot-instructions.md` exist?
   - No → Use `create-workflow.md`
   - Yes → Continue to step 2

2. **User intent detection:** What did the user request?
   - Contains "create", "initialize", "new" → Use `create-workflow.md`
   - Contains "update", "recent", "incremental" → Use `update-workflow.md`
   - Contains "review", "comprehensive", "refactor", "validate" → Use `refactor-workflow.md`
   - Default (copilot-instructions.md exists, no clear signal) → Use `update-workflow.md`

3. **Context validation:**
   - If create-workflow selected but copilot-instructions.md exists → Ask user: "copilot-instructions.md
     already exists. Update it or recreate from scratch?"
   - If update/refactor selected but copilot-instructions.md missing → Switch to create-workflow

### Step 2: Load and Execute Workflow

Based on detection result, load the appropriate reference file:

- **Create:** `view` and follow `references/create-workflow.md`
- **Update:** `view` and follow `references/update-workflow.md`
- **Refactor:** `view` and follow `references/refactor-workflow.md`

Each workflow contains complete step-by-step instructions specific to that scenario.

### Step 3: Verify and Report

After completing the workflow:

- Confirm copilot-instructions.md reflects accurate repository state
- Report what was accomplished (created/updated/reviewed)
- Summarize key changes made (if applicable)

## File Locations

GitHub Copilot supports multiple instruction file locations with specific precedence:

1. **Repository-wide instructions:** `.github/copilot-instructions.md` (primary, recommended)
2. **Path-specific instructions:** `.github/instructions/NAME.instructions.md` (requires `applyTo: "glob"` frontmatter)
3. **Legacy support:** `AGENTS.md` at repository root (still supported, but `.github/copilot-instructions.md` is preferred)
4. **User-specific instructions:** `$HOME/.copilot/copilot-instructions.md` (local machine only)

**Default behavior:** This skill manages `.github/copilot-instructions.md` unless the user explicitly specifies a
different location.

## Success Criteria

- Correct workflow selected based on context
- copilot-instructions.md accurately reflects repository reality
- Content is concise, actionable, and uses imperative form
- All commands are verified and accurate
- Critical warnings and conventions are highlighted
- For refactor workflow: User approved all applied changes
