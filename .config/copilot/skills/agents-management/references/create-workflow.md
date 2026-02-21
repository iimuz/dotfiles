# Create Workflow

Generate `.github/copilot-instructions.md` from scratch by analyzing the entire codebase.

## Goal

Analyze the codebase and create a concise project context file that helps AI agents understand the repository quickly
and work effectively.

## When to Use

- Repository lacks `.github/copilot-instructions.md`
- Existing project context file is outdated or incomplete
- User explicitly asks to create project documentation for AI agents from scratch

## Instructions

### 1. Analyze the Repository

Explore the codebase to identify:

- Project type and main technologies (framework, language, libraries)
- Directory structure and architectural patterns
- Build/test/lint commands (check package.json, Makefile, mise.toml, pyproject.toml, etc.)
- Code conventions (imports style, formatting, naming patterns)
- Critical security/deployment notes

Use the `explore` agent or grep/glob tools to efficiently gather this information.

### 2. Create Structured Documentation

Generate a markdown file with these sections (adapt based on project type):

### Project Header

- One-line description of the project and its tech stack

**Code Style** (if applicable)

- Language-specific conventions
- Import/export patterns
- Styling approach

### Commands

- Development server
- Build process
- Testing (unit, integration, e2e)
- Linting/formatting
- Database migrations

### Architecture

- Directory structure with brief explanations
- Key design patterns
- Important modules/components

### Important Notes

- Security warnings (secrets, authentication)
- Deployment considerations
- Common pitfalls
- References to detailed docs if available

### 3. Keep It Concise

- Use bullet points, not paragraphs
- Focus on actionable information
- Avoid explaining obvious framework defaults
- Reference external docs with `@path/to/doc.md` when appropriate
- Aim for 20-40 lines total

### 4. Output Format

Save as `.github/copilot-instructions.md` (create `.github/` directory if needed).

For reference structure, see:

- `references/template.md` - Blank template
- `references/example.md` - Concrete example

**Note:** For path-specific instructions, use `.github/instructions/NAME.instructions.md` with frontmatter:

```yaml
---
applyTo: "src/**/*.ts"
---
```

Legacy `AGENTS.md` at repository root is still supported but `.github/copilot-instructions.md` is preferred.

## Success Criteria

- File is created and contains all relevant sections
- Information is accurate based on actual codebase analysis
- Content is concise and actionable (not verbose explanations)
- Critical warnings and conventions are highlighted
