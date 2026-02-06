---
name: update-agents
description: This skill updates AGENTS.md based on recent repository changes identified from git diff and work history. This skill should be used after significant code changes to keep project context current for AI agents.
---

## Goal

Review recent repository changes and update AGENTS.md to reflect current architecture, commands, and conventions.

## When to Use This Skill

- After completing feature implementation or refactoring
- Repository structure has changed (new directories, moved files)
- Build/test/deploy commands have been modified
- New code conventions or patterns have been established
- User explicitly requests AGENTS.md update

## Instructions

### 1. Identify Recent Changes

Check recent work and modifications:

```bash
## Review last 5 commits (adjust range based on scope of changes; use fewer for young repos)
git --no-pager diff HEAD~5..HEAD -- . ':!*.lock' ':!package-lock.json' ':!yarn.lock'

## Recent commit history for broader context
git --no-pager log --oneline -10
```

Look for:

- New directories or file structure changes
- Added/removed dependencies
- Modified build/test scripts
- Changed configuration files

### 2. Update AGENTS.md Sections

Use concise, actionable, imperative-form content when updating. For each section:

**Architecture**

- Add new directories with brief purpose
- Update file structure if significantly changed
- Remove obsolete paths

**Commands**

- Add new build/test/deployment commands
- Update modified script names or flags
- Remove deprecated commands

**Code Style & Conventions**

- Document new patterns discovered during implementation
- Add warnings about common pitfalls AI agents encountered
- Update import/export patterns if changed

**Important Notes**

- Add security considerations from new features
- Document breaking changes or migration steps
- Remove resolved issues

### 3. Verify Accuracy

- Cross-check updates against actual codebase state
- Use glob/grep to confirm all referenced file paths exist in the repository
- Cross-check directory descriptions against actual directory contents

### 4. Report Changes

If updates made:

- Summarize what sections were changed and why

If no updates needed:

- Report "No updates required - AGENTS.md is current"

## Success Criteria

- AGENTS.md reflects current repository state
- All commands are accurate and verified
- New architecture changes are documented
- Obsolete information is removed
- Changes are concise, actionable, and use imperative form
