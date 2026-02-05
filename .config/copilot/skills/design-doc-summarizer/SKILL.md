---
name: design-doc-summarizer
description: Transform detailed implementation materials into concise, high-level design documents that capture architectural decisions without implementation details.
---

# Design Document Summarizer

## Overview

This skill converts technical implementation plans, specifications, and detailed documents into maintainable design documentation. Transform verbose implementation materials into structured, concise design documents that enable future readers to understand system architecture without getting lost in implementation details.

## When to Use This Skill

Invoke this skill when:

- Converting implementation plans to high-level design documentation
- Creating architectural summaries from detailed technical specifications
- Generating reference documents that focus on design decisions rather than code
- Documenting system changes without exposing implementation details
- Building maintainable design docs from detailed materials

## Core Capabilities

Generate design documents that:

- Capture essential architectural information and component relationships
- Exclude implementation details (code, file paths, line numbers, function names)
- Structure content for easy comprehension of system overview
- Remain self-contained and understandable without reference materials
- Follow consistent document structure for maintainability

## Workflow

### 1. Analyze Input Materials

Extract key information while filtering:

- **Include**: Architecture, interfaces, design decisions, data flows, migration strategies
- **Exclude**: Source code, file paths, line numbers, function names, task checklists, verification commands, detailed IaC configurations

### 2. Structure Document

Follow this mandatory 6-section structure (omit sections that do not apply):

**Section 1: Overview & Purpose**

- Background: Why this change is needed
- Goal: What to achieve
- Scope: Range of changes

**Section 2: Architecture**

- Before/After configuration (simple diagram or bullet points)
- Role of main resources (table format)

**Section 3: Specification**

- Interface definitions (URL, API, etc.)
- Prerequisites and constraints

**Section 4: Key Design Decisions**

- Key design decisions and their reasons
- Briefly mention alternatives that were not chosen, if any

**Section 5: Processing Flow**

- Data flow, authorization flow, etc. as needed

**Section 6: Migration Plan**

- Phased approach and impact on existing resources (only if applicable)

### 3. Apply Quality Standards

Before finalizing, verify:

- All implementation details have been removed
- Document is understandable without original reference materials
- Key design decisions include reasoning
- Architecture changes are clearly explained
- Specifications are complete but concise
- Sections without applicable content are omitted

## Output Standards

Generate documents using:

- **Concise language** optimized for future reference
- **Tables** for comparing before/after states or listing components
- **Bullet points** for lists and constraints
- **Simple text diagrams** when helpful for visualization
- **Focused sections** without redundancy

Default to English unless user specifies another language.

## Key Constraints

**Strict Exclusions:**

- No source code or code snippets
- No file paths or directory structures
- No line numbers or function references
- No implementation task checklists
- No verification commands or test procedures
- No detailed CDK/IaC configurations

**Focus Requirements:**

- Maintain architectural perspective throughout
- Prioritize design decisions over implementation choices
- Keep content self-contained and reference-free
- Ensure readability for future maintainers
