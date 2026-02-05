# Implementation Patterns

Detailed implementation examples for the multi-agent cross-review workflow.

## Session Files Protocol

All subagent outputs must be saved to session files for proper workflow coordination.

**Location**: `~/.copilot/session-state/{session-id}/files/`

**Naming Convention**: `[step]-[model]-[component]-[timestamp].md`

Examples:
- `step1-gpt-analysis-20260205.md`
- `step2-gemini-review-20260205.md`
- `consolidated-findings-20260205.md`

**Benefits**:
- Persistent outputs across subagent invocations
- Clear audit trail of multi-agent workflow
- Easy reference passing between subagents
- Enables parallel execution without context conflicts

## Parallel Subagent Invocation

Execute the same task across multiple models simultaneously, each writing to session files:

```python
# Step 1 execution across three models
step_prompt = f"""
{step_context}

Output: Save analysis to session files as step1-gpt-analysis-20260205.md
Location: ~/.copilot/session-state/{{session-id}}/files/
"""
task(agent_type="general-purpose", model="gpt-5.2-codex", prompt=step_prompt)
task(agent_type="general-purpose", model="gemini-3-pro-preview", prompt=step_prompt)
task(agent_type="general-purpose", model="claude-sonnet-4.5", prompt=step_prompt)
```

## Cross-Review Pattern

Reference session files from previous step for peer review:

```python
review_context = f"""
Review these analyses saved in session files:

Read and analyze:
- step1-gpt-analysis-20260205.md
- step1-gemini-analysis-20260205.md
- step1-claude-analysis-20260205.md

Location: ~/.copilot/session-state/{{session-id}}/files/

Task: Identify gaps, conflicts, best insights, confidence levels
Output: Save review to step2-{{model}}-review-20260205.md
"""

# Each agent reviews all outputs from session files
task(agent_type="general-purpose", model="gpt-5.2-codex", prompt=review_context)
task(agent_type="general-purpose", model="gemini-3-pro-preview", prompt=review_context)
task(agent_type="general-purpose", model="claude-sonnet-4.5", prompt=review_context)
```

## Consolidation Strategy (Subagent-Driven)

Each consolidation task is delegated to specialized subagents.

### 1. Common Findings Aggregation

Extract consensus points from all agent reviews in session files:

```python
aggregation_prompt = f"""
Read these review files from session files:
- step2-gpt-review-20260205.md
- step2-gemini-review-20260205.md
- step2-claude-review-20260205.md

Location: ~/.copilot/session-state/{{session-id}}/files/

Task: Identify consensus points and shared insights.
Output: Save to consolidated-findings-20260205.md
"""
task(agent_type="general-purpose", model="gpt-5.2-codex", prompt=aggregation_prompt)
```

### 2. Conflict Resolution (Per-Conflict Subagent)

Resolve each conflict independently with dedicated subagent, referencing session files:

```python
conflict_prompt = f"""
Read review files to resolve this conflict:
Files: step2-*-review-20260205.md
Location: ~/.copilot/session-state/{{session-id}}/files/

Conflict: {identified_conflict_description}

Task: Determine optimal resolution using evidence-based analysis.
Output: Save resolution to conflict-resolution-{conflict_id}-20260205.md
"""
task(agent_type="general-purpose", model="claude-sonnet-4.5", prompt=conflict_prompt)
```

**Important**: Each conflict gets its own subagent invocation. Do not batch conflicts. All outputs saved to session files.

### 3. Unique Insights Validation

Assess feasibility and value of model-specific insights from session files:

```python
insights_prompt = f"""
Read analysis and review files to extract unique insights:
Files: step1-*-analysis-20260205.md, step2-*-review-20260205.md
Location: ~/.copilot/session-state/{{session-id}}/files/

Task: Assess feasibility and value of each unique insight.
Output: Save to validated-insights-20260205.md
"""
task(agent_type="general-purpose", model="gemini-3-pro-preview", prompt=insights_prompt)
```

### 4. Final Synthesis

Merge all consolidated results from session files into unified output:

```python
synthesis_prompt = f"""
Read consolidated outputs from session files:
- consolidated-findings-20260205.md
- conflict-resolution-*-20260205.md
- validated-insights-20260205.md

Location: ~/.copilot/session-state/{{session-id}}/files/

Task: Produce unified, coherent result for this step.
Output: Save to step2-final-synthesis-20260205.md
"""
task(agent_type="general-purpose", model="gpt-5.2-codex", prompt=synthesis_prompt)
```

## Complete Workflow Example

```python
# Session files location
session_files = "~/.copilot/session-state/{session-id}/files/"
timestamp = "20260205"

# Step 1: Analyze Request - Parallel execution with session file outputs
step1_prompt = f"""
Analyze: Add JWT authentication to Express API

Output: Save analysis to {session_files}step1-{{model}}-analysis-{timestamp}.md
"""
task(agent_type="general-purpose", model="gpt-5.2-codex", prompt=step1_prompt)
task(agent_type="general-purpose", model="gemini-3-pro-preview", prompt=step1_prompt)
task(agent_type="general-purpose", model="claude-sonnet-4.5", prompt=step1_prompt)

# Cross-review - Reference session files from Step 1
review_prompt = f"""
Read and review these analyses from session files:
- step1-gpt-analysis-{timestamp}.md
- step1-gemini-analysis-{timestamp}.md
- step1-claude-analysis-{timestamp}.md

Location: {session_files}

Identify gaps, conflicts, best insights.
Output: Save review to {session_files}step2-{{model}}-review-{timestamp}.md
"""
task(agent_type="general-purpose", model="gpt-5.2-codex", prompt=review_prompt)
task(agent_type="general-purpose", model="gemini-3-pro-preview", prompt=review_prompt)
task(agent_type="general-purpose", model="claude-sonnet-4.5", prompt=review_prompt)

# Consolidation - Reference all review session files
consolidation_prompt = f"""
Read these review files:
- step2-gpt-review-{timestamp}.md
- step2-gemini-review-{timestamp}.md
- step2-claude-review-{timestamp}.md

Location: {session_files}

Consolidate findings, resolve conflicts, validate insights.
Output: Save to {session_files}step2-consolidated-{timestamp}.md
"""
task(agent_type="general-purpose", model="claude-sonnet-4.5", prompt=consolidation_prompt)

# Step 3: Generate Final Plan - Reference consolidated session file
plan_prompt = f"""
Read consolidated analysis: {session_files}step2-consolidated-{timestamp}.md

Generate implementation plan following template.md structure.
Output: Save final plan to {session_files}feature-jwt-auth-1.md
"""
task(agent_type="general-purpose", model="gpt-5.2-codex", prompt=plan_prompt)
```
