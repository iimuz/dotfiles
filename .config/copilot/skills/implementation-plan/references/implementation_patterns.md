# Implementation Patterns

Detailed implementation examples for the multi-agent cross-review workflow.

## Parallel Subagent Invocation

Execute the same task across multiple models simultaneously:

```python
# Step 1 execution across three models
task(agent_type="general-purpose", model="gpt-5.2-codex", prompt=step_context)
task(agent_type="general-purpose", model="gemini-3-pro-preview", prompt=step_context)
task(agent_type="general-purpose", model="claude-sonnet-4.5", prompt=step_context)
```

## Cross-Review Pattern

Pass all agent outputs to all agents for peer review:

```python
review_context = f"""
Analyze these outputs from multiple agents:

Agent 1 (GPT-5.2-Codex): {output1}
Agent 2 (Gemini 3 Pro): {output2}
Agent 3 (Claude Sonnet 4.5): {output3}

Identify: gaps, conflicts, best insights, confidence levels
"""

# Each agent reviews all outputs
task(agent_type="general-purpose", model="gpt-5.2-codex", prompt=review_context)
task(agent_type="general-purpose", model="gemini-3-pro-preview", prompt=review_context)
task(agent_type="general-purpose", model="claude-sonnet-4.5", prompt=review_context)
```

## Consolidation Strategy (Subagent-Driven)

Each consolidation task is delegated to specialized subagents.

### 1. Common Findings Aggregation

Extract consensus points from all agent reviews:

```python
aggregation_prompt = f"""
Extract common findings across these agent outputs:
{all_review_results}

Task: Identify consensus points and shared insights.
Output: Structured list of validated common findings.
"""
task(agent_type="general-purpose", model="gpt-5.2-codex", prompt=aggregation_prompt)
```

### 2. Conflict Resolution (Per-Conflict Subagent)

Resolve each conflict independently with dedicated subagent:

```python
conflict_prompt = f"""
Resolve this specific conflict between agent outputs:
Conflict: {identified_conflict}
Agent A position: {position_a}
Agent B position: {position_b}
Agent C position: {position_c}

Task: Determine optimal resolution using evidence-based analysis.
Output: Single resolved decision with rationale.
"""
task(agent_type="general-purpose", model="claude-sonnet-4.5", prompt=conflict_prompt)
```

**Important**: Each conflict gets its own subagent invocation. Do not batch conflicts.

### 3. Unique Insights Validation

Assess feasibility and value of model-specific insights:

```python
insights_prompt = f"""
Validate these unique insights from individual agents:
{unique_findings_list}

Task: Assess feasibility and value of each unique insight.
Output: Curated list of validated insights with risk scores.
"""
task(agent_type="general-purpose", model="gemini-3-pro-preview", prompt=insights_prompt)
```

### 4. Final Synthesis

Merge all consolidated results into unified output:

```python
synthesis_prompt = f"""
Synthesize final output from:
- Common findings: {aggregated_findings}
- Resolved conflicts: {conflict_resolutions}
- Validated insights: {unique_insights}

Task: Produce unified, coherent result for this step.
Output: Consolidated document ready for next step.
"""
task(agent_type="general-purpose", model="gpt-5.2-codex", prompt=synthesis_prompt)
```

## Complete Workflow Example

```python
# Step 1: Analyze Request
step1_context = "Analyze: Add JWT authentication to Express API"

# Parallel execution
gpt_analysis = task(agent_type="general-purpose", model="gpt-5.2-codex", prompt=step1_context)
gemini_analysis = task(agent_type="general-purpose", model="gemini-3-pro-preview", prompt=step1_context)
claude_analysis = task(agent_type="general-purpose", model="claude-sonnet-4.5", prompt=step1_context)

# Cross-review
review_prompt = f"""
Review these analyses:
GPT: {gpt_analysis}
Gemini: {gemini_analysis}
Claude: {claude_analysis}

Identify gaps, conflicts, best insights.
"""
gpt_review = task(agent_type="general-purpose", model="gpt-5.2-codex", prompt=review_prompt)
gemini_review = task(agent_type="general-purpose", model="gemini-3-pro-preview", prompt=review_prompt)
claude_review = task(agent_type="general-purpose", model="claude-sonnet-4.5", prompt=review_prompt)

# Consolidation
consolidated = consolidate_reviews([gpt_review, gemini_review, claude_review])

# Step 2: Structure Plan (repeat pattern)
# Step 3: Generate Plan (repeat pattern)
# Step 4: Save to session files folder
```
