---
name: task-orchestrator
description: Coordinate complex tasks by delegating to specialized subagents. This skill should be used when tasks require breaking down into multiple subtasks that can be handled by different specialized agents in parallel or sequence.
---

# Task Orchestrator

Decompose complex requests into subtasks, delegate to specialized agents, and synthesize results. This skill enables efficient task coordination by leveraging specialized agents for their strengths while maintaining overall workflow control.

## When to Use This Skill

Use this skill when:

- Complex tasks require multiple specialized capabilities (research + implementation + review)
- Subtasks can be parallelized for efficiency
- Tasks need coordination across different domains (frontend + backend + infrastructure)
- Work requires systematic delegation rather than direct implementation

Do NOT use for:

- Simple single-step tasks
- Quick fixes or trivial changes
- Tasks better suited for direct implementation

## Core Process

Follow this three-step process for all orchestration tasks:

### 1. Decompose

Identify independent, parallelizable subtasks:

- Break complex requests into discrete units of work
- Determine dependencies between subtasks
- Identify which subtasks can run in parallel

### 2. Delegate

Call subagents using the task tool:

- Select appropriate agent based on subtask type (see `references/agent_catalog.md`)
- Provide minimal required context (file paths, specific questions)
- Define clear scope: what to do AND what NOT to do
- Specify expected output format/signal
- Use parallel calls when subtasks are independent

### 3. Synthesize

Collect and verify results:

- Verify completeness of each subtask
- Provide inline summary (3-5 sentences)
- Update dashboard with outcomes

## Delegation Template

For each subtask, structure delegation as follows:

```
Agent: [explore|task|general-purpose|code-review|language-specific|workflow]
Context: [Minimal info - file paths not contents, specific questions not broad goals]
Scope: [What to do AND what NOT to do]
Success: [Expected output format/signal]
Output: [Optional] "If analysis is substantial, create output: YYYYMMDD_HHMMSS_<topic>.md"
```

## Parallelization Strategy

Maximize efficiency through parallel execution:

- Call multiple agents simultaneously when tasks are independent
- Make multiple task tool invocations in a single response (parallel execution)
- Chain dependent tasks sequentially (use previous output as input)

Example parallel execution (3 independent tasks in one response):

```
<invoke name="task"> agent="explore" → Find auth files
<invoke name="task"> agent="code-review" → Review security
<invoke name="task"> agent="task" → Run tests
```

## Agent Selection

Reference `references/agent_catalog.md` for complete agent capabilities. Quick selection guide:

**Research/Discovery**: explore (parallel-safe)
**Commands/Tests**: task (side effects)
**Complex Implementation**: general-purpose or language-specific agents
**Quality Review**: code-review (parallel-safe)
**Planning**: implementation-plan, specification
**Debugging**: debug

**Model Override**: Use model parameter for complexity-appropriate selection:

- Simple: gpt-5-mini, haiku
- Standard: sonnet, gpt-5.2-codex
- Complex: opus

## Output Management

### Dashboard Tracking

Maintain `dashboard.md` in session files to track overall task status:

- **Location**: Session folder (`~/.copilot/session-state/{sessionId}/files/dashboard.md`)
- Update at task completion, not during delegation
- Check if exists → update; otherwise create using `assets/dashboard_template.md`
- Structure: Pending / Questions / Completed
- Include: Agent used, task performed, outcome, timestamp

### Subagent Documentation

When subtask warrants substantial documentation, include in subagent prompt:

```
"If your analysis is substantial, create output: YYYYMMDD_HHMMSS_<topic>.md"
```

Examples:

- `20250204_090000_api_vulnerability_analysis.md`
- `20250204_093000_performance_investigation.md`

File location: Session folder (`~/.copilot/session-state/{sessionId}/files/`)

Do NOT create files for simple tasks where results fit in inline summary.

## Anti-Patterns to Avoid

**DON'T** implement code directly - always delegate
**DON'T** ask subagents for advice instead of execution
**DON'T** duplicate context across multiple agents
**DON'T** make sequential calls when parallel is possible
**DON'T** proceed without validating critical results

## Error Handling

If subagent fails:

1. Refine prompt with more specific context
2. Retry once with improved instructions
3. If still fails, report to user with context and alternative approaches

## Bundled Resources

### References

- `references/agent_catalog.md` - Complete catalog of available agents, their capabilities, and when to use each

### Assets

- `assets/dashboard_template.md` - Template for creating task tracking dashboards
