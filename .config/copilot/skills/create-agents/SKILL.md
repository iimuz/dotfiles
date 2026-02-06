---
name: create-agents
description: This skill creates or updates AGENTS.md files to provide repository context for AI agents. This skill should be used when a repository needs structured documentation about its architecture, commands, and conventions.
---

# Goal

Analyze the codebase and create a concise project context file that helps AI agents understand the repository quickly and work effectively.

# When to Use This Skill

- Repository lacks AGENTS.md
- Existing project context file is outdated or incomplete
- User explicitly asks to create/update project documentation for AI agents

# Instructions

## 1. Analyze the Repository

Explore the codebase to identify:

- Project type and main technologies (framework, language, libraries)
- Directory structure and architectural patterns
- Build/test/lint commands (check package.json, Makefile, etc.)
- Code conventions (imports style, formatting, naming patterns)
- Critical security/deployment notes

Use the `explore` agent or grep/glob tools to efficiently gather this information.

## 2. Create Structured Documentation

Generate a markdown file with these sections (adapt based on project type):

**Project Header**

- One-line description of the project and its tech stack

**Code Style** (if applicable)

- Language-specific conventions
- Import/export patterns
- Styling approach

**Commands**

- Development server
- Build process
- Testing (unit, integration, e2e)
- Linting/formatting
- Database migrations

**Architecture**

- Directory structure with brief explanations
- Key design patterns
- Important modules/components

**Important Notes**

- Security warnings (secrets, authentication)
- Deployment considerations
- Common pitfalls
- References to detailed docs if available

## 3. Keep It Concise

- Use bullet points, not paragraphs
- Focus on actionable information
- Avoid explaining obvious framework defaults
- Reference external docs with `@path/to/doc.md` when appropriate
- Aim for 20-40 lines total

## 4. Output Format

Save as one of these filenames (ask user preference if unclear):

- `AGENTS.md` - General AI agent context

## Example Structure

See `references/template.md` for a complete template structure.

# Success Criteria

- File is created and contains all relevant sections
- Information is accurate based on actual codebase analysis
- Content is concise and actionable (not verbose explanations)
- Critical warnings and conventions are highlighted
