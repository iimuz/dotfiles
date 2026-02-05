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

## Workflow

Execute all steps using multi-agent delegation for higher quality and parallel execution.

### Step 1: Multi-Agent Requirement Analysis

**Purpose**: Analyze requirements from multiple specialized perspectives in parallel

**Subagents (4 parallel invocations)**:
1. **Requirements & Scope** (gpt-5.2-codex): Extract functional/non-functional requirements, scope boundaries, success criteria
2. **Architecture & Feasibility** (claude-sonnet-4.5): Evaluate technical approach, codebase patterns, integration points
3. **Dependencies & Impact** (gemini-3-pro-preview): Map file/module dependencies, assess cross-component impacts
4. **Risk Assessment** (gpt-5.1-codex): Identify technical risks, resource constraints, security considerations

**Delegation Pattern**:
```
For each specialized agent, invoke task tool with:
- Agent type: general-purpose
- Model: Specified above
- Prompt: Analysis focus + output file specification
- Output: {session-files}/step1{a-d}-{focus}-{timestamp}.md
```

**Outputs**: 4 analysis files in session files folder
- `step1a-requirements-{timestamp}.md`
- `step1b-architecture-{timestamp}.md`
- `step1c-dependencies-{timestamp}.md`
- `step1d-risks-{timestamp}.md`

See `references/implementation_patterns.md` for complete code examples.

### Step 2: Multi-Agent Plan Generation & Cross-Review

**Purpose**: Generate multiple independent plan drafts and cross-review for quality

**Sub-Step 2A - Plan Generation (3 parallel invocations)**:
Each agent reads all 4 Step 1 analysis files and generates complete implementation plan following `references/template.md` structure.

1. **GPT-5.2-Codex**: Generate plan draft from consolidated analysis
2. **Claude Sonnet 4.5**: Generate independent plan draft
3. **Gemini 3 Pro**: Generate independent plan draft

**Sub-Step 2B - Cross-Review (3 parallel invocations)**:
Each agent reads all 3 plan drafts and identifies:
- Gaps (missing tasks, incomplete phases)
- Conflicts (contradictory approaches, incompatible dependencies)
- Best practices (superior task breakdowns, better validation criteria)

**Delegation Pattern**:
```
Sub-Step 2A: Each agent reads step1{a-d}-*.md files, outputs step2-{model}-plan-draft-{timestamp}.md
Sub-Step 2B: Each agent reads step2-*-plan-draft-*.md files, outputs step2-{model}-review-{timestamp}.md
```

**Outputs**: 6 files in session files folder
- `step2-{model}-plan-draft-{timestamp}.md` (3 files)
- `step2-{model}-review-{timestamp}.md` (3 files)

### Step 3: Multi-Agent Consolidation & Final Plan Generation

**Purpose**: Consolidate multi-agent outputs into single authoritative plan

**Sub-Steps (sequential, 3-5 subagent invocations)**:

**3A. Consensus Aggregation** (1 agent, claude-sonnet-4.5):
Read all review files, extract shared insights and universally agreed-upon best practices.
Output: `step3a-consensus-{timestamp}.md`

**3B. Conflict Resolution** (1 agent per conflict, gpt-5.2-codex):
For each identified conflict, invoke dedicated subagent to resolve using evidence-based analysis.
Output: `step3b-conflict-{id}-{timestamp}.md`

**3C. Insight Validation** (1 agent, gemini-3-pro-preview):
Assess model-specific unique insights for technical feasibility and value-add.
Output: `step3c-insights-{timestamp}.md`

**3D. Final Synthesis** (1 agent, gpt-5.2-codex):
Read all consolidation outputs and generate final authoritative plan following `references/template.md` structure exactly.
Output: `{purpose}-{component}-{version}.md`

**Delegation Pattern**:
```
Sequential execution:
1. Read step2-*-review-*.md → Consensus
2. Read reviews + drafts → Resolve each conflict independently
3. Read drafts + reviews → Validate unique insights
4. Read step3{a-c}-*.md + drafts → Synthesize final plan
```

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

## Reference Materials

- `references/template.md` - Mandatory plan template structure
- `references/implementation_patterns.md` - Multi-agent workflow code examples
- `references/examples.md` - Complete plan examples for various scenarios
- `references/api_reference.md` - Quick reference guide with patterns and conventions
