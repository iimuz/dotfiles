# Implementation Patterns

Workflow coordination guide for the multi-agent implementation planning process.

## Session Files Protocol

All subagent outputs must be saved to session files for proper workflow coordination.

**CRITICAL: Always use the complete path with session-id**

- **Location**: `~/.copilot/session-state/{session-id}/files/`
- **INCORRECT (DO NOT USE)**: `~/.copilot/session-state/files/` (missing session-id)
- **CORRECT**: `~/.copilot/session-state/{session-id}/files/`
- **Naming Convention**: `[step]-[model]-[timestamp].md` or `[step]-[model]-[component]-[timestamp].md`

Examples:
- `step1-claude-opus-4.6-20260218064435.md`
- `step2-gemini-3-pro-preview-plan-draft-20260218064435.md`
- `step2-gpt-5.3-codex-review-20260218064435.md`
- `feature-jwt-auth-1.md`

**Benefits**:
- Persistent outputs across subagent invocations
- Clear audit trail of multi-agent workflow
- Easy reference passing between subagents
- Enables parallel execution without context conflicts

## Step 1: Parallel Analysis

Launch 3 `task()` calls simultaneously, each injecting the user's implementation request and a unique `{output_filepath}`:

```
task(agent_type="general-purpose", model="claude-opus-4.6", description="Step 1 Analysis - Claude",
     prompt=<analysis-prompt.md with {user_request}, {codebase_context}, {output_filepath}=step1-claude-opus-4.6-{timestamp}.md>)

task(agent_type="general-purpose", model="gemini-3-pro-preview", description="Step 1 Analysis - Gemini",
     prompt=<analysis-prompt.md with {user_request}, {codebase_context}, {output_filepath}=step1-gemini-3-pro-preview-{timestamp}.md>)

task(agent_type="general-purpose", model="gpt-5.3-codex", description="Step 1 Analysis - GPT",
     prompt=<analysis-prompt.md with {user_request}, {codebase_context}, {output_filepath}=step1-gpt-5.3-codex-{timestamp}.md>)
```

Each agent analyzes all four aspects: Requirements & Scope, Architecture & Feasibility, Dependencies & Impact, and Risk Assessment.

## Step 2A: Plan Drafting

After Step 1 outputs are available, launch 3 parallel `task()` calls. Each agent reads all Step 1 analysis files from the session folder and generates a complete implementation plan following `references/template.md`:

```
task(agent_type="general-purpose", model="claude-opus-4.6", description="Step 2A Draft - Claude",
     prompt=<read step1-*-{timestamp}.md from session folder; generate full plan per template.md; save to step2-claude-opus-4.6-plan-draft-{timestamp}.md>)

task(agent_type="general-purpose", model="gemini-3-pro-preview", description="Step 2A Draft - Gemini",
     prompt=<read step1-*-{timestamp}.md from session folder; generate full plan per template.md; save to step2-gemini-3-pro-preview-plan-draft-{timestamp}.md>)

task(agent_type="general-purpose", model="gpt-5.3-codex", description="Step 2A Draft - GPT",
     prompt=<read step1-*-{timestamp}.md from session folder; generate full plan per template.md; save to step2-gpt-5.3-codex-plan-draft-{timestamp}.md>)
```

## Step 2B: Cross-Review

After Step 2A outputs are available, launch 3 parallel `task()` calls. Each agent reads all three plan drafts and identifies gaps, conflicts, and best practices:

```
task(agent_type="general-purpose", model="claude-opus-4.6", description="Step 2B Review - Claude",
     prompt=<read step2-*-plan-draft-{timestamp}.md from session folder; identify gaps, conflicts, best practices; save to step2-claude-opus-4.6-review-{timestamp}.md>)

task(agent_type="general-purpose", model="gemini-3-pro-preview", description="Step 2B Review - Gemini",
     prompt=<read step2-*-plan-draft-{timestamp}.md from session folder; identify gaps, conflicts, best practices; save to step2-gemini-3-pro-preview-review-{timestamp}.md>)

task(agent_type="general-purpose", model="gpt-5.3-codex", description="Step 2B Review - GPT",
     prompt=<read step2-*-plan-draft-{timestamp}.md from session folder; identify gaps, conflicts, best practices; save to step2-gpt-5.3-codex-review-{timestamp}.md>)
```

## Step 3: Consolidation Strategy

Execute 3A first, then launch 3B and 3C in parallel, then 3D after both complete.

### 3A. Consensus Aggregation (run first)

```
task(agent_type="general-purpose", model="claude-opus-4.6", description="Step 3A Consensus",
     prompt=<read step2-*-review-{timestamp}.md from session folder; extract shared insights and universally agreed best practices; identify conflicts for 3B; save to step3a-consensus-{timestamp}.md>)
```

### 3B and 3C (launch in parallel after 3A completes)

#### 3B. Conflict Resolution (single task)

Read the 3A consensus output, identify all conflicts, and resolve them in a single pass:

```
task(agent_type="general-purpose", model="gpt-5.3-codex", description="Step 3B Conflict Resolution",
     prompt=<read step3a-consensus-{timestamp}.md from session folder at ~/.copilot/session-state/{session-id}/files/; identify all conflicts listed; resolve each one with evidence-based analysis; save all resolutions to step3b-resolutions-{timestamp}.md>)
```

#### 3C. Insight Validation

```
task(agent_type="general-purpose", model="gemini-3-pro-preview", description="Step 3C Insight Validation",
     prompt=<read step2-*-plan-draft-{timestamp}.md and step2-*-review-{timestamp}.md from session folder; assess feasibility and value of model-specific unique insights; save to step3c-insights-{timestamp}.md>)
```

### 3D. Final Synthesis (after 3B and 3C complete)

```
task(agent_type="general-purpose", model="gpt-5.3-codex", description="Step 3D Final Synthesis",
     prompt=<read synthesis-prompt.md; session-id={session-id}; user_request={user_request}; output_filepath=~/.copilot/session-state/{session-id}/files/{purpose}-{component}-{version}.md; the synthesis-prompt.md contains instructions to self-discover all step2 and step3 intermediate files from the session folder; generate authoritative final plan per template.md; save as {purpose}-{component}-{version}.md>)
```
