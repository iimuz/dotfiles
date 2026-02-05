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

### 1. Structured Plan Generation

Generate implementation plans with:
- **Discrete phases**: Independent work units with measurable completion criteria
- **Atomic tasks**: Specific actions with file paths, function names, exact details
- **Dependency mapping**: Explicit cross-phase and cross-task dependencies
- **Validation criteria**: Automatically verifiable success conditions

### 2. AI-Optimized Formatting

Structure all content for machine parsing:
- Explicit, zero-ambiguity language
- Machine-parseable formats (tables, lists, structured data)
- Specific file paths, line numbers, code references
- Standardized identifier prefixes (REQ-, TASK-, PHASE-)
- Complete context within each task description

### 3. Plan Lifecycle Management

Track plan evolution through statuses:
- **Planned** (blue badge) - Ready but not started
- **In progress** (yellow badge) - Actively executing
- **Completed** (green badge) - All tasks finished
- **On Hold** (orange badge) - Paused temporarily
- **Deprecated** (red badge) - No longer relevant

## How to Use

### Multi-Agent Cross-Review Workflow

This skill implements a multi-model consensus approach for high-quality planning:

#### Step 1: Analyze the Request (Multi-Agent)

**Execution**: Delegate to multiple subagents in parallel with identical context:
- **Models**: `gpt-5.2-codex`, `gemini-3-pro-preview`, `claude-sonnet-4.5`
- **Task**: Gather context about:
  - Specific feature, refactor, or change to implement
  - Codebase structure, dependencies, current state
  - Technical constraints and requirements
  - Target outcomes and success criteria

**Cross-Review**: Pass all analysis results to the same subagents for evaluation
- Each agent reviews outputs from all other agents
- Identifies gaps, conflicts, and complementary insights
- Produces consolidated analysis with confidence levels

**Consolidation**: Merge subagent results into unified context document

#### Step 2: Structure the Plan (Multi-Agent)

**Execution**: Delegate to multiple subagents in parallel with consolidated context from Step 1:
- **Models**: `gpt-5.2-codex`, `gemini-3-pro-preview`, `claude-sonnet-4.5`
- **Task**: Break work into phases:
  - Each phase has measurable completion criteria
  - Tasks within phases executable in parallel (unless dependencies specified)
  - No task requires human interpretation or decision-making
  - All identifiers use standardized prefixes

**Cross-Review**: Pass all structure proposals to the same subagents for evaluation
- Each agent reviews phase breakdowns from all other agents
- Identifies optimal task granularity and dependency mapping
- Produces refined structure with risk assessments

**Consolidation**: Merge subagent results into optimal phase structure

#### Step 3: Generate the Plan (Multi-Agent)

**Execution**: Delegate to multiple subagents in parallel with consolidated structure from Step 2:
- **Models**: `gpt-5.2-codex`, `gemini-3-pro-preview`, `claude-sonnet-4.5`
- **Task**: Create plan file following template structure (see `references/template.md`):
  - Front matter with metadata and status
  - Introduction with context and scope
  - Detailed phases with tasks in table format
  - Dependencies explicitly declared
  - Validation criteria for each phase

**Cross-Review**: Pass all generated plans to the same subagents for evaluation
- Each agent reviews complete plans from all other agents
- Validates template compliance and execution feasibility
- Produces final plan with quality scores

**Consolidation**: Select best plan or merge strengths from multiple plans

#### Step 4: Save and Track

Output plan to:
- **Location**: Session files folder (`~/.copilot/session-state/{session-id}/files/`)
- **Naming**: `[purpose]-[component]-[version].md`
- **Purpose prefixes**: upgrade | refactor | feature | data | infrastructure | process | architecture | design

Examples:
- `upgrade-node-runtime-2.md`
- `feature-auth-module-1.md`
- `refactor-command-system-3.md`

### Implementation Details

The workflow uses subagents at every stage:
- **Parallel Execution**: Same task sent to `gpt-5.2-codex`, `gemini-3-pro-preview`, `claude-sonnet-4.5`
- **Cross-Review**: All outputs reviewed by all agents
- **Consolidation**: Subagents aggregate findings, resolve conflicts, validate insights, synthesize final output

Each conflict is resolved by a dedicated subagent invocation (not batched).

See `references/implementation_patterns.md` for detailed code examples and patterns.

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

### Required Sections

1. **Front Matter**: Status, version, identifiers, metadata
2. **Introduction**: Context, scope, objectives, status badge
3. **Phases**: Discrete work units with completion criteria
4. **Tasks**: Atomic actions in table format with specifics
5. **Dependencies**: Explicit mappings between tasks/phases
6. **Validation**: Automated verification criteria

### Task Specification Format

Each task includes:
- **Task ID**: Unique identifier (TASK-###)
- **Description**: Specific action with file paths and details
- **Files**: Exact paths to modify/create
- **Dependencies**: Prerequisites (TASK-### IDs)
- **Validation**: How to verify completion

See `references/template.md` for the complete mandatory template structure.

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
