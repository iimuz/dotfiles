# Agent Catalog

Complete reference of available specialized agents and their capabilities.

## Built-in Agents

### explore

- **Purpose**: Codebase research, code search, file discovery
- **Tools**: grep, glob, view
- **Model**: Haiku (fast)
- **When to use**: Finding files by patterns, searching code for keywords, answering questions about codebase structure
- **Parallel-safe**: Yes

### task

- **Purpose**: Command execution with verbose output
- **Use cases**: Tests, builds, lints, dependency installs
- **Model**: Haiku (fast)
- **Output**: Brief summary on success, full output on failure
- **Parallel-safe**: No (side effects)

### general-purpose

- **Purpose**: Complex multi-step implementation tasks
- **Tools**: All CLI tools
- **Model**: Sonnet (high-quality reasoning)
- **When to use**: Tasks requiring complete toolset and sophisticated reasoning
- **Parallel-safe**: No (side effects)

### code-review

- **Purpose**: Code quality and security verification
- **Focus**: Only surfaces critical issues (bugs, security, logic errors)
- **Will NOT**: Modify code or comment on style/formatting
- **When to use**: Reviewing staged/unstaged changes, branch diffs
- **Parallel-safe**: Yes

## Language-Specific Agents

### typescript-pro

- **Language**: TypeScript/JavaScript
- **Specialization**: Type-safe development, modern TS features
- **When to use**: TypeScript codebases, complex type systems

### python-pro

- **Language**: Python 3.11+
- **Specialization**: Modern Python features, typing, best practices
- **When to use**: Python development with focus on type safety

### golang-pro

- **Language**: Go
- **Specialization**: Systems programming, concurrency patterns
- **When to use**: Go services, CLI tools, backend systems

### rust-engineer

- **Language**: Rust
- **Specialization**: Memory-safe development, ownership patterns
- **When to use**: Systems programming requiring memory safety

### export-react-frontend-engineer

- **Language**: React 19.2
- **Specialization**: Modern React development, frontend architecture
- **When to use**: React applications, component design

## Workflow Agents

### implementation-plan

- **Purpose**: Feature planning and task breakdown
- **Output**: Structured implementation plan with tasks
- **When to use**: Before starting complex features or refactoring

### specification

- **Purpose**: Specification document generation
- **When to use**: Formalizing requirements into technical specs

### design-doc-summarizer

- **Purpose**: Design document creation from implementation details
- **When to use**: Summarizing technical decisions into high-level docs

### debug

- **Purpose**: Application debugging to find and fix bugs
- **When to use**: Investigating and resolving runtime issues

### commit-message-generator

- **Purpose**: Generate conventional commit messages
- **When to use**: Creating standardized commit messages

### create-pr

- **Purpose**: Pull request generation from branch changes
- **When to use**: Automating PR creation workflow

### jira-to-issue

- **Purpose**: JIRA to GitHub issue conversion
- **When to use**: Migrating JIRA tickets to GitHub issues

## Architecture/Review Agents

### cloud-architect

- **Specialization**: Multi-cloud architecture design
- **Expertise**: AWS, Azure, GCP
- **Focus**: Security, performance, compliance, cost-effectiveness
- **When to use**: Designing cloud infrastructure, architecture reviews

### code-reviewer

- **Purpose**: Proactive quality review during development
- **When to use**: Regular code quality checks, pre-PR reviews

## Model Selection Guidelines

### Simple/Fast Tasks

- **Models**: gpt-5-mini, haiku
- **Use for**: Quick searches, simple commands, straightforward tasks
- **Cost**: Low

### Standard Tasks

- **Models**: sonnet, gpt-5.2-codex, gemini
- **Use for**: Most implementation work, code generation, debugging
- **Cost**: Medium

### Complex Tasks

- **Models**: opus
- **Use for**: Architecture decisions, complex refactoring, critical systems
- **Cost**: High
