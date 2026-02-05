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

### Step 1: Analyze Request and Gather Context

Investigate the requirement:
- Identify specific feature, refactor, or change to implement
- Explore codebase structure, dependencies, and current state
- Document technical constraints and requirements
- Define target outcomes and success criteria

### Step 2: Generate Structured Plan

Create implementation plan with:
- Discrete phases broken into atomic, parallelizable tasks
- Explicit dependency mapping between tasks and phases
- Measurable completion criteria for each phase
- File paths, function names, and exact implementation details
- Validation criteria for automated verification

Follow template structure in `references/template.md`:
- Front matter with metadata and status
- Introduction with context and scope
- Phases table with tasks in structured format
- Dependency declarations using standardized IDs (TASK-###)
- Validation criteria for each phase

**Multi-Agent Approach**: For complex plans, use parallel subagent analysis and cross-review workflow. See `references/implementation_patterns.md` for detailed patterns.

### Step 3: Save and Track

Output plan to session files folder:
- **Location**: `~/.copilot/session-state/{session-id}/files/`
- **Naming**: `[purpose]-[component]-[version].md`
- **Purpose prefixes**: upgrade | refactor | feature | data | infrastructure | process | architecture | design

Examples:
- `upgrade-node-runtime-2.md`
- `feature-auth-module-1.md`
- `refactor-command-system-3.md`

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
