# Implementation Plan Skill - Reference Guide

## Quick Reference

This document provides quick-reference information for using the implementation-plan skill effectively.

## File Naming Quick Reference

```
[purpose]-[component]-[version].md

Purpose Prefixes:
├── upgrade       → System/dependency version updates
├── refactor      → Code restructuring (no feature changes)
├── feature       → New functionality additions
├── data          → Database/storage schema changes
├── infrastructure → DevOps/deployment/CI-CD changes
├── process       → Workflow/tooling improvements
├── architecture  → Structural design changes
└── design        → UI/UX implementation

Examples:
- upgrade-node-runtime-2.md
- refactor-auth-module-1.md
- feature-oauth-integration-1.md
- data-user-schema-3.md
- infrastructure-k8s-deployment-1.md
```

## Identifier Prefix Reference

| Prefix | Usage | Format | Example |
|--------|-------|--------|---------|
| `PLAN-` | Plan identifier (unique) | PLAN-### | PLAN-042 |
| `OBJ-` | Objective in plan | OBJ-### | OBJ-001 |
| `REQ-` | Requirement | REQ-### | REQ-015 |
| `PHASE-` | Implementation phase | PHASE-# | PHASE-3 |
| `TASK-` | Individual task | TASK-### | TASK-127 |
| `DEC-` | Design decision | DEC-### | DEC-003 |
| `DEP-` | Dependency | DEP-### | DEP-042 |
| `RISK-` | Risk identification | RISK-### | RISK-008 |
| `TEST-` | Unit test | TEST-### | TEST-055 |
| `INT-` | Integration test | INT-### | INT-012 |
| `E2E-` | End-to-end test | E2E-### | E2E-004 |
| `VAL-` | Validation criterion | VAL-### | VAL-009 |
| `DOC-` | Documentation item | DOC-### | DOC-017 |
| `CRIT-` | Success criteria | CRIT-### | CRIT-002 |

## Status Values & Colors

| Status | Color | Badge Code | When to Use |
|--------|-------|------------|-------------|
| Planned | blue | `![Planned](https://img.shields.io/badge/Status-Planned-blue)` | Plan created, not started |
| In progress | yellow | `![In Progress](https://img.shields.io/badge/Status-In%20Progress-yellow)` | Actively executing tasks |
| Completed | green | `![Completed](https://img.shields.io/badge/Status-Completed-brightgreen)` | All tasks finished |
| On Hold | orange | `![On Hold](https://img.shields.io/badge/Status-On%20Hold-orange)` | Paused, will resume |
| Deprecated | red | `![Deprecated](https://img.shields.io/badge/Status-Deprecated-red)` | Cancelled or replaced |

## Task Table Format

Required columns for all task tables:

```markdown
| Task ID | Description | Files Modified | Dependencies | Owner | Status |
|---------|-------------|----------------|--------------|-------|--------|
| TASK-001 | [Action with specifics] | `path/to/file.ts` | None | [Name] | Not Started |
| TASK-002 | [Action with specifics] | `path/to/test.ts` | TASK-001 | [Name] | Not Started |
```

### Task Description Guidelines

**Good (Specific & Actionable):**
- ✅ "Add authentication middleware in `src/middleware/auth.ts` implementing JWT validation"
- ✅ "Update User model in `models/User.js` adding email, passwordHash, createdAt fields"
- ✅ "Create integration test in `test/auth.integration.ts` covering login/logout flow"

**Bad (Vague & Non-Actionable):**
- ❌ "Implement authentication"
- ❌ "Update the user model"
- ❌ "Add tests"

## Phase Structure Template

```markdown
### PHASE-X: [Clear Phase Name]

**Completion Criteria:**
- [Measurable criterion 1]
- [Measurable criterion 2]

**Estimated Duration:** [Time estimate]

**Tasks:**

| Task ID | Description | Files Modified | Dependencies | Owner | Status |
|---------|-------------|----------------|--------------|-------|--------|
| TASK-### | [Specific action] | [Files] | [Deps] | [Owner] | Not Started |

**Validation:**
- VAL-###: [How to verify this phase is complete]
```

## Dependency Notation

### Task Dependencies

Within a phase:
```markdown
| Task ID | Dependencies |
|---------|--------------|
| TASK-001 | None |
| TASK-002 | TASK-001 |
| TASK-003 | TASK-001, TASK-002 |
```

### Cross-Phase Dependencies

```markdown
## Dependencies

### Internal Dependencies

| Dep ID | From Task | To Task | Type | Status |
|--------|-----------|---------|------|--------|
| DEP-101 | TASK-010 | TASK-003 | Blocking | Active |
```

## Common Validation Patterns

### Code Validation
```markdown
- VAL-001: All unit tests pass with >80% coverage
- VAL-002: TypeScript compilation succeeds with zero errors
- VAL-003: Linter passes with zero warnings
- VAL-004: Build completes successfully
```

### Integration Validation
```markdown
- VAL-010: Integration tests pass for all endpoints
- VAL-011: Database migrations run without errors
- VAL-012: API response times <200ms for p99
```

### Deployment Validation
```markdown
- VAL-020: Staging deployment successful
- VAL-021: Smoke tests pass in staging
- VAL-022: Performance benchmarks meet targets
- VAL-023: Security scan shows no critical issues
```

## Risk Assessment Matrix

| Probability | Impact | Action Required |
|-------------|--------|-----------------|
| High | High | Mandatory mitigation plan |
| High | Medium | Mitigation plan recommended |
| Medium | High | Mitigation plan recommended |
| Medium | Medium | Monitor closely |
| Low | Any | Document only |

## Common Plan Patterns

### Feature Addition Pattern
```
PHASE-1: Data/Schema Changes
PHASE-2: Business Logic Implementation
PHASE-3: API/Interface Layer
PHASE-4: Testing & Validation
PHASE-5: Documentation & Rollout
```

### Refactoring Pattern
```
PHASE-1: Analysis & Design
PHASE-2: Create New Structure
PHASE-3: Migration (incremental)
PHASE-4: Deprecate Old Structure
PHASE-5: Cleanup & Validation
```

### Upgrade Pattern
```
PHASE-1: Compatibility Audit
PHASE-2: Configuration Updates
PHASE-3: Code Changes
PHASE-4: Testing & Validation
PHASE-5: Deployment & Monitoring
```

### Infrastructure Pattern
```
PHASE-1: Infrastructure Provisioning
PHASE-2: Configuration & Setup
PHASE-3: Service Deployment
PHASE-4: Integration & Testing
PHASE-5: Monitoring & Rollout
```

## Best Practices Checklist

### Plan Quality
- [ ] Title clearly describes the implementation
- [ ] Context provides sufficient background
- [ ] Objectives are specific and measurable
- [ ] Scope explicitly defines boundaries (in/out)
- [ ] Success criteria are verifiable

### Task Quality
- [ ] Each task has specific file paths
- [ ] Descriptions use deterministic language
- [ ] No task requires human interpretation
- [ ] Dependencies explicitly declared
- [ ] Tasks are atomic (single responsibility)

### Validation Quality
- [ ] Each phase has validation criteria
- [ ] Validation is automatable where possible
- [ ] Success metrics are measurable
- [ ] Rollback procedures defined
- [ ] Monitoring metrics specified

### Documentation Quality
- [ ] All identifiers use correct prefixes
- [ ] Tables include all required columns
- [ ] No placeholder text remains
- [ ] Proper markdown formatting
- [ ] Change log maintained

## Common Pitfalls to Avoid

### ❌ Avoid
- Vague task descriptions ("Update the code")
- Missing file paths or specifics
- Ambiguous success criteria
- Circular dependencies
- Tasks requiring human decisions
- Placeholder text (TODO, TBD)
- Mixing multiple concerns in one task

### ✅ Instead
- Specific actions ("Add login() method to AuthService in src/auth/AuthService.ts")
- Explicit file paths and function names
- Measurable validation criteria
- Acyclic dependency graphs
- Deterministic task descriptions
- Complete, final content
- Atomic, single-purpose tasks

## Template Compliance Validation

Before finalizing a plan, verify against template.md:

1. **Front Matter**: All required fields present
2. **Sections**: All mandatory sections included
3. **Identifiers**: Correct prefixes and numbering
4. **Tables**: All required columns present
5. **Dependencies**: Explicitly declared
6. **Validation**: Criteria for each phase
7. **Files**: Specific paths throughout
8. **Language**: Deterministic, zero-ambiguity
9. **Status**: Correct badge and color
10. **Completeness**: No TODOs or placeholders
