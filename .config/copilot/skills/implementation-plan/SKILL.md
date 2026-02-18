---
name: implementation-plan
description: Generate structured, machine-executable implementation plans for features, refactoring, and system changes. Use when breaking down complex development tasks into deterministic, AI-actionable phases.
---

# Implementation Plan Generator

## Overview

Generate deterministic, structured implementation plans designed for AI-to-AI communication and automated execution. Creates fully self-contained plans that are immediately actionable by AI agents or human developers without requiring interpretation.

## When to Use This Skill

Invoke this skill when:

- **Starting new features** requiring detailed planning and phased execution
- **Refactoring complex code** with multiple dependencies and risk points
- **Upgrading systems** (frameworks, runtimes, architectures)
- **Creating infrastructure** or data migration plans
- **Breaking down large tasks** into atomic, parallelizable work units
- Need **deterministic plans** executable by AI agents without human decisions

## Core Capabilities

- **Discrete phases**: Independent work units with measurable completion criteria
- **Atomic tasks**: Specific actions with file paths, function names, exact details
- **Dependency mapping**: Explicit cross-phase and cross-task dependencies
- **Validation criteria**: Automatically verifiable success conditions
- **AI-optimized formatting**: Zero-ambiguity language with machine-parseable structures
- **Lifecycle tracking**: Status badges (Planned, In Progress, Completed, On Hold, Deprecated)

## Model Configuration

| Role | Model | Provider | Purpose |
|------|-------|----------|---------|
| Analyzer 1 | `claude-opus-4.6` | Anthropic | Deep reasoning and architecture insights |
| Analyzer 2 | `gemini-3-pro-preview` | Google | Broad knowledge and alternative perspectives |
| Analyzer 3 | `gpt-5.3-codex` | OpenAI | Structured thinking and code-focused analysis |
| Consolidator | `claude-opus-4.6` | Anthropic | Consensus aggregation (Step 3A) |
| Conflict Resolver | `gpt-5.3-codex` | OpenAI | Evidence-based conflict resolution (Step 3B) |
| Insight Validator | `gemini-3-pro-preview` | Google | Technical feasibility assessment (Step 3C) |
| Synthesizer | `gpt-5.3-codex` | OpenAI | Final authoritative plan generation (Step 3D) |

## Critical File Output Requirements

**ALL intermediate and final outputs MUST be saved to the session files folder:**

- **Location**: `~/.copilot/session-state/{session-id}/files/`
- **Never use**: `~/.copilot/session-state/files/` (missing session-id)
- **In subagent prompts**: Always specify the full path explicitly including `{session-id}`
- **Verification**: Ensure all delegated agents receive exact path in their prompts

## Workflow

Execute all steps using multi-agent delegation for higher quality and parallel execution.

### Step 1: Multi-Agent Requirement Analysis

**Purpose**: Analyze requirements from multiple specialized perspectives in parallel

1. Read [references/analysis-prompt.md](references/analysis-prompt.md).
2. Inject `{user_request}` with the implementation task description.
3. Inject `{codebase_context}` with relevant codebase information (file structure, existing patterns, key components).
4. Inject `{output_filepath}` = `~/.copilot/session-state/{session-id}/files/step1-{model}-{timestamp}.md` for each agent, where `{timestamp}` uses format `YYYYMMDDHHMMSS`.
5. Launch 3 parallel `task()` calls:

```
task(agent_type="general-purpose", model="claude-opus-4.6", description="Step 1 Analysis - Claude", prompt=<analysis-prompt with injected request and filepath>)
task(agent_type="general-purpose", model="gemini-3-pro-preview", description="Step 1 Analysis - Gemini", prompt=<analysis-prompt with injected request and filepath>)
task(agent_type="general-purpose", model="gpt-5.3-codex", description="Step 1 Analysis - GPT", prompt=<analysis-prompt with injected request and filepath>)
```

6. Collect responses. If fewer than 2 succeed, abort with error: "Analysis quorum not met: fewer than 2 analyses received." If exactly 2 succeed, continue with a degraded-mode notice appended to the final output.

**Outputs**: 3 analysis files in session files folder (`~/.copilot/session-state/{session-id}/files/`)

| File | Content |
|------|---------|
| `step1-claude-opus-4.6-{timestamp}.md` | Claude's multi-perspective analysis |
| `step1-gemini-3-pro-preview-{timestamp}.md` | Gemini's multi-perspective analysis |
| `step1-gpt-5.3-codex-{timestamp}.md` | GPT's multi-perspective analysis |

### Step 2: Multi-Agent Plan Generation & Cross-Review

**Purpose**: Generate multiple independent plan drafts and cross-review for quality

**Sub-Step 2A - Plan Generation (3 parallel invocations)**:
Each agent reads all 3 Step 1 analysis files and generates complete implementation plan following `references/template.md` structure.

1. **GPT-5.3-Codex**: Generate plan draft from consolidated analysis
2. **Claude Opus 4.6**: Generate independent plan draft
3. **Gemini 3 Pro**: Generate independent plan draft

**Sub-Step 2B - Cross-Review (3 parallel invocations)**:
Each agent reads all 3 plan drafts and identifies:

- Gaps (missing tasks, incomplete phases)
- Conflicts (contradictory approaches, incompatible dependencies)
- Best practices (superior task breakdowns, better validation criteria)

**Sub-Step 2A Delegation** (launch 3 parallel tasks):

```
task(agent_type="general-purpose", model="claude-opus-4.6", description="Step 2A Draft - Claude", prompt=<read step1-*-{timestamp}.md files from session folder; generate full plan following references/template.md; save to step2-claude-opus-4.6-plan-draft-{timestamp}.md>)
task(agent_type="general-purpose", model="gemini-3-pro-preview", description="Step 2A Draft - Gemini", prompt=<read step1-*-{timestamp}.md files from session folder; generate full plan following references/template.md; save to step2-gemini-3-pro-preview-plan-draft-{timestamp}.md>)
task(agent_type="general-purpose", model="gpt-5.3-codex", description="Step 2A Draft - GPT", prompt=<read step1-*-{timestamp}.md files from session folder; generate full plan following references/template.md; save to step2-gpt-5.3-codex-plan-draft-{timestamp}.md>)
```

**Sub-Step 2B Delegation** (launch 3 parallel tasks):

```
task(agent_type="general-purpose", model="claude-opus-4.6", description="Step 2B Review - Claude", prompt=<read all step2-*-plan-draft-{timestamp}.md files from session folder; identify gaps, conflicts, and best practices; save review to step2-claude-opus-4.6-review-{timestamp}.md>)
task(agent_type="general-purpose", model="gemini-3-pro-preview", description="Step 2B Review - Gemini", prompt=<read all step2-*-plan-draft-{timestamp}.md files from session folder; identify gaps, conflicts, and best practices; save review to step2-gemini-3-pro-preview-review-{timestamp}.md>)
task(agent_type="general-purpose", model="gpt-5.3-codex", description="Step 2B Review - GPT", prompt=<read all step2-*-plan-draft-{timestamp}.md files from session folder; identify gaps, conflicts, and best practices; save review to step2-gpt-5.3-codex-review-{timestamp}.md>)
```

**Outputs**: 6 files in session files folder (`~/.copilot/session-state/{session-id}/files/`)

- `step2-{model}-plan-draft-{timestamp}.md` (3 files)
- `step2-{model}-review-{timestamp}.md` (3 files)

### Step 3: Multi-Agent Consolidation & Final Plan Generation

**Purpose**: Consolidate multi-agent outputs into single authoritative plan

**Sub-Steps (3A first, then 3B and 3C in parallel, then 3D)**:

**3A. Consensus Aggregation** (1 agent, claude-opus-4.6):
Read all review files, extract shared insights and universally agreed-upon best practices.
Output: `~/.copilot/session-state/{session-id}/files/step3a-consensus-{timestamp}.md`

**3B. Conflict Resolution** (1 agent, gpt-5.3-codex):
Read the 3A consensus output, identify all conflicts, and resolve each one with evidence-based analysis in a single pass.
Output: `~/.copilot/session-state/{session-id}/files/step3b-resolutions-{timestamp}.md`

**3C. Insight Validation** (1 agent, gemini-3-pro-preview):
Assess model-specific unique insights for technical feasibility and value-add.
Output: `~/.copilot/session-state/{session-id}/files/step3c-insights-{timestamp}.md`

**3D. Final Synthesis** (1 agent, gpt-5.3-codex):
Read all consolidation outputs and generate final authoritative plan following `references/template.md` structure exactly.
Output: `~/.copilot/session-state/{session-id}/files/{purpose}-{component}-{version}.md`

**Delegation Pattern** (3A → [3B + 3C in parallel] → 3D):

**3A** (run first):
```
task(agent_type="general-purpose", model="claude-opus-4.6", description="Step 3A Consensus", prompt=<read all step2-*-review-{timestamp}.md from session folder; extract shared insights and universally agreed best practices; identify conflicts for 3B; save to step3a-consensus-{timestamp}.md>)
```

**3B and 3C** (launch in parallel after 3A completes):

3B (single task):
```
task(agent_type="general-purpose", model="gpt-5.3-codex", description="Step 3B Conflict Resolution", prompt=<read step3a-consensus-{timestamp}.md from session folder at ~/.copilot/session-state/{session-id}/files/; identify all conflicts listed; resolve each one with evidence-based analysis; save all resolutions to step3b-resolutions-{timestamp}.md>)
```

3C:
```
task(agent_type="general-purpose", model="gemini-3-pro-preview", description="Step 3C Insight Validation", prompt=<read step2-*-plan-draft-{timestamp}.md and step2-*-review-{timestamp}.md from session folder; assess feasibility and value of model-specific unique insights; save to step3c-insights-{timestamp}.md>)
```

**3D** (after 3B and 3C complete):
```
task(agent_type="general-purpose", model="gpt-5.3-codex", description="Step 3D Final Synthesis", prompt=<read synthesis-prompt.md; session-id={session-id}; user_request={user_request}; output_filepath=~/.copilot/session-state/{session-id}/files/{purpose}-{component}-{version}.md; the synthesis-prompt.md contains instructions to self-discover all step2 and step3 intermediate files from the session folder; generate authoritative final plan per template.md; save as {purpose}-{component}-{version}.md>)
```

**After Step 3D completes**: Return the file path of the final plan (`~/.copilot/session-state/{session-id}/files/{purpose}-{component}-{version}.md`) to the caller. Do NOT read the file content into the main agent context -- the caller can read it directly.

**Final Output**: Implementation plan in session files folder

- **Location**: `~/.copilot/session-state/{session-id}/files/`
- **Naming**: `{purpose}-{component}-{version}.md`
- **Purpose prefixes**: upgrade | refactor | feature | data | infrastructure | process | architecture | design
- **Examples**: `upgrade-node-runtime-2.md`, `feature-auth-module-1.md`, `refactor-command-system-3.md`

## Plan Structure Standards

### File Naming Convention

`[purpose]-[component]-[version].md`

**Purpose prefixes:**

- `upgrade`: System/dependency version updates
- `refactor`: Code restructuring without feature changes
- `feature`: New functionality additions
- `data`: Database/storage changes
- `infrastructure`: DevOps/deployment changes
- `process`: Workflow/tooling improvements
- `architecture`: Structural design changes
- `design`: UI/UX implementation

### Task Specification Format

Each task includes:

- **Task ID**: Unique identifier (TASK-###)
- **Description**: Specific action with file paths and details
- **Files**: Exact paths to modify/create
- **Dependencies**: Prerequisites (TASK-### IDs)
- **Validation**: How to verify completion

See `references/template.md` for complete template structure and required sections.

## Examples

Brief overview of use cases. See `references/examples.md` for complete implementations.

### Example 1: Feature Addition

**Input**: "Add JWT-based user authentication"  
**Output**: 4-phase plan with 12 tasks covering database, JWT service, endpoints, testing

### Example 2: System Refactor

**Input**: "Refactor legacy command system to plugin architecture"  
**Output**: 4-phase plan with 12 tasks covering interface design, extraction, plugin loader, validation

### Example 3: Infrastructure Upgrade

**Input**: "Upgrade from Node 16 to Node 20"  
**Output**: 4-phase plan with 12 tasks covering audit, configuration, code compatibility, CI/CD

## Key Constraints

### Read-Only Operation

- Only generate plans, never make code edits
- Plans describe what to do, agents/humans execute

### Self-Contained Plans

- All context included within plan document
- No external dependencies for understanding
- No assumptions about reader's prior knowledge

### Deterministic Execution

- Zero ambiguity in task descriptions
- Explicit file paths, function names, values
- Enable automated execution without decisions

### Parallel-Safe Tasks

- Tasks executable in parallel unless dependencies specified
- Dependencies explicitly declared with TASK-### IDs
- Phases independent unless cross-phase dependencies noted

## Session Files

All files are saved to `~/.copilot/session-state/{session-id}/files/`:

| File | Content |
|------|---------|
| `step1-claude-opus-4.6-{timestamp}.md` | Claude's multi-perspective analysis |
| `step1-gemini-3-pro-preview-{timestamp}.md` | Gemini's multi-perspective analysis |
| `step1-gpt-5.3-codex-{timestamp}.md` | GPT's multi-perspective analysis |
| `step2-claude-opus-4.6-plan-draft-{timestamp}.md` | Claude's plan draft |
| `step2-gemini-3-pro-preview-plan-draft-{timestamp}.md` | Gemini's plan draft |
| `step2-gpt-5.3-codex-plan-draft-{timestamp}.md` | GPT's plan draft |
| `step2-claude-opus-4.6-review-{timestamp}.md` | Claude's cross-review |
| `step2-gemini-3-pro-preview-review-{timestamp}.md` | Gemini's cross-review |
| `step2-gpt-5.3-codex-review-{timestamp}.md` | GPT's cross-review |
| `step3a-consensus-{timestamp}.md` | Consensus aggregation |
| `step3b-resolutions-{timestamp}.md` | All conflict resolutions (single file) |
| `step3c-insights-{timestamp}.md` | Validated unique insights |
| `{purpose}-{component}-{version}.md` | Final implementation plan |

Timestamps use format `YYYYMMDDHHMMSS` (e.g., `20260218064435`). The `{session-id}` is the actual session UUID from `~/.copilot/session-state/`.

## Error Handling

| Condition | Behavior |
|-----------|----------|
| Step 1: Fewer than 2 analyses succeed | Abort with "Analysis quorum not met" error |
| Step 1: Exactly 2 analyses succeed | Continue in degraded mode; note it in final output |
| Step 2A: Fewer than 2 plan drafts generated | Abort; restart Step 2A with adjusted prompt |
| Step 2B: All reviewers fail | Abort; restart Step 2B with adjusted prompts |
| Step 2B: Review parse failure on 1 reviewer | Skip that reviewer; note in Step 3A consolidation |
| Step 3A or 3C: Failure | Pass available outputs directly to Step 3D with fallback notice |
| Step 3B: No conflicts identified | Skip Step 3B; proceed directly to Step 3C |
| Step 3D: Failure | Present the highest-quality Step 2A draft as fallback with notice |

## Invocation Example

```
# Step 1: invoke the skill
skill: implementation-plan

# Step 2: describe your implementation task in the conversation
"Add JWT-based authentication to the Express API"
```

Example tasks well-suited for the Implementation Plan skill:
- "Refactor the legacy command system to a plugin architecture"
- "Upgrade from Node 16 to Node 20"
- "Implement a database migration from MySQL to PostgreSQL"
- "Add real-time WebSocket notifications to the existing REST API"

## Reference Materials

- `references/template.md` - Mandatory plan template structure
- `references/analysis-prompt.md` - Step 1 multi-perspective analysis prompt
- `references/synthesis-prompt.md` - Step 3D final synthesis prompt
- `references/implementation_patterns.md` - Workflow coordination guide
- `references/examples.md` - Complete plan examples for various scenarios
- `references/api_reference.md` - Quick reference guide with patterns and conventions
