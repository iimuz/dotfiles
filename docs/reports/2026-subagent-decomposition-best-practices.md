# Report: Subagent Task Decomposition Best Practices for Data Retrieval & Analysis Workflows

## Context

This report answers four questions about subagent granularity for an AI
orchestration system, specifically a CloudWatch Logs investigation orchestrator
that dispatches a subagent to (a) query AWS CLI, (b) save artifacts,
(c) analyze data, and (d) decide if the investigation needs another iteration.

---

## Executive Summary

Community best practices across LangGraph, AutoGen, CrewAI, OpenAI Swarm, and
AWS Bedrock converge on separating retrieval from analysis when the retrieval
output is consumed partially. They also unanimously recommend combining them
when retrieval and analysis are tightly coupled in an iterative loop.

For the CloudWatch investigation pattern specifically, the evidence strongly
favors keeping retrieval + analysis + resolution-decision in a single subagent
per iteration cycle, provided the subagent returns structured results
(not raw log data) back to the orchestrator. The anti-pattern is not the
combination itself. It is the subagent returning raw content that causes
orchestrator context bloat.

---

## Architecture Overview

The two patterns under consideration:

```text
Pattern A: Combined (Retrieve-and-Analyze)
──────────────────────────────────────────
Orchestrator
    │
    └─► Investigation Subagent (one per iteration)
            ├── Query AWS CLI / fetch logs
            ├── Save artifacts to disk
            ├── Analyze retrieved data
            └── Decide: RESOLVED or ITERATE
                    │
                    └─► Returns: { status, findings, next_query } ◄── structured only

Pattern B: Split (Retrieve-then-Analyze)
─────────────────────────────────────────
Orchestrator
    │
    ├─► Retrieval Subagent
    │       ├── Query AWS CLI
    │       └── Save artifacts
    │               │
    │               └─► Returns: raw data OR structured facts
    │
    └─► Analysis Subagent (receives data from Retrieval)
            ├── Analyze data
            └── Decide: RESOLVED or ITERATE
                    │
                    └─► Returns: judgment
```

---

## Question 1: Should Retrieval and Analysis Be Split?

### The general case: YES, split is canonical in stateless workflows

All major agentic frameworks use separation of retrieval from analysis as their
canonical multi-agent example:

- AutoGen `SelectorGroupChat` explicitly creates two separate agents:
  `WebSearchAgent` and `DataAnalystAgent`.[^1]
  - `WebSearchAgent`: "Your only tool is search_tool — use it to find
    information. You make only one search call at a time. Once you have the
    results, you never do calculations based on them."
  - `DataAnalystAgent`: "analyze the data and provide results using the tools
    provided"
- CrewAI uses `researcher` for data gathering and `reporting_analyst` for
  synthesis as its canonical YAML configuration example.[^2]
- OpenAI Swarm and its successor OpenAI Agents SDK model agents as routines:
  a bounded set of steps with specific tools. Retrieval routines and analysis
  routines are expected to hand off.[^3]
- AWS Bedrock multi-agent explicitly documents "minimize overlapping
  responsibilities" as a core rule when assigning collaborator agents.[^4]

The rationale in every framework is the same: single-responsibility agents have
smaller, more reliable context windows and produce more predictable outputs.

### The iterative investigation case: NO, combined is the right pattern

The separation advice applies to stateless, sequential pipelines where data
flows linearly from retrieval → analysis → report. It does not automatically
apply to iterative investigation loops where:

1. The analysis determines which data to retrieve next.
   The retrieval query is informed by analysis of prior results.
2. The decision to terminate the loop depends on both the raw data and the
   analysis of it being in the same context.
3. The subagent is actually the entire one iteration of the loop, not a
   standalone capability.

For CloudWatch investigation, this is the dominant pattern: each subagent
invocation represents one full investigative cycle. The subagent must hold both
the retrieved logs and the reasoning about those logs to decide whether the
investigation is resolved.

Splitting would introduce coordination overhead without benefit. The
orchestrator would need to pass raw log data from the retrieval agent to the
analysis agent, reintroducing the context bloat that the subagent pattern was
meant to avoid.

---

## Question 2: Trade-offs of Splitting Retrieval from Reasoning in Iterative Loops

- Context window
  - Split: Analysis subagent receives already-filtered facts if the retrieval
    agent summarizes first, or suffers bloat if raw data is passed through.
  - Combined: The subagent holds all context needed for one iteration, while
    the orchestrator only sees structured results.
- Iteration coherence
  - Split: The orchestrator must track retrieval state and pass context to the
    analysis subagent on each iteration.
  - Combined: A single agent owns one full iteration loop, so coherence is
    maintained naturally.
- Reusability
  - Split: The retrieval agent can be reused across different analysis tasks.
  - Combined: The combined agent is purpose-specific.
- Specialization
  - Split: Each agent can use a model optimized for its task, such as a
    faster or cheaper model for retrieval.
  - Combined: One model handles both tasks and may be over-specified for
    simple retrieval.
- Error isolation
  - Split: Failures are precisely located as either retrieval or analysis
    failures.
  - Combined: Diagnosis must happen within the combined agent.
- Prompt simplicity
  - Split: Each agent prompt is shorter and more focused.
  - Combined: A single prompt covers more steps and has a more complex
    instruction set.
- Coordination cost
  - Split: High. The orchestrator must route data between agents on every
    iteration.
  - Combined: Low. The orchestrator only receives one structured result per
    cycle.
- Data fidelity
  - Split: There is a risk that the retrieval agent over-filters before the
    analysis agent sees the data.
  - Combined: The analysis agent has full access to raw data and can make its
    own filtering decisions.

For iterative investigation, the trade-offs favor the combined pattern. The
retrieved data in iteration N shapes the analysis in iteration N, which shapes
the retrieval query for iteration N+1. Inserting an agent boundary within that
loop creates a coordination problem without solving any context-management
problem.

The only scenario where splitting helps in an iterative loop is when the
retrieval subagent is very heavy, such as querying multiple AWS regions in
parallel, and the analysis subagent can be a cheaper, faster model that
processes retrieved facts. In that case, the retrieval agent still summarizes
and filters before returning, and the split is about cost optimization rather
than architecture.

---

## Question 3: Community Best Practices on Subagent Granularity

### The core principle: delegate by goal, not by operation

This repository has already captured the correct principle in its own
investigation reports. From
`docs/reports/2026-03-05-orchestrator-delegation.md`:[^5]

> ALWAYS delegate as goal-oriented missions, not as tool operations.
>
> - Wrong: "Read service/runtime/handler.go and return its contents"
> - Wrong: "Run golangci-lint and return the output"
> - Right: "Analyze the handler module's error handling patterns and report
>   which functions lack context wrapping"
> - Right: "Implement the cache invalidation logic per the spec, run lint and
>   tests, and report pass/fail with any issues found"

This exactly matches the established industry principle. AutoGen's planning
agent says it only plans and delegates tasks and does not execute them itself.[^1]
OpenAI's Swarm documentation likewise states that agents can represent a very
specific workflow or step defined by a set of instructions and functions,
including a complex retrieval.[^3]

### Decision rule: when to split vs. combine

From synthesis across all frameworks, the decision rule is:

Split into separate agents when:

- The retrieval output is consumed partially. The analysis agent only needs a
  subset of fields from retrieved data. This matches the data utilization rate
  gate from
  `docs/reports/2026-03-03-subagent-delegation-failure-report.md`.[^6]
- The retrieval and analysis are independently reusable across different
  workflows.
- The tasks run in a linear sequence where one produces a stable artifact the
  next consumes.
- The tasks require different model capabilities, such as a tool-calling model
  for retrieval and a reasoning model for analysis.
- There is no iterative feedback loop between retrieval and analysis.

Combine into one agent when:

- Retrieval and analysis are in a tight feedback loop. Analysis determines what
  to retrieve next.
- The agent needs full access to raw data to make analysis decisions, not just
  summaries.
- Each agent invocation represents one complete iteration of an investigation
  cycle.
- The work is bounded, so the single agent will not accumulate unbounded
  context.
- The decision to terminate depends on evaluating both data and reasoning in
  one pass.

### The data utilization rate gate (from this repository)

`docs/reports/2026-03-03-subagent-delegation-failure-report.md`[^6] defines a
practical decision gate that is fully consistent with industry practice:

> Sub-agent Delegation Decision Gate:
>
> - BEFORE any data-fetching call in coordinator context, apply this gate:
>   "Will I use every field of the returned data directly in this context?"
> - If the answer is NO: delegate to a sub-agent. Receive only the filtered
>   facts needed.
> - If the answer is YES: proceed in coordinator context.

For CloudWatch investigation, the orchestrator does not need every log line.
It needs the investigation outcome. So the full retrieval + analysis cycle
belongs in the subagent.

---

## Question 4: Established Patterns for Retrieve-then-Analyze vs. Retrieve-and-Analyze

### Pattern: Retrieve-then-Analyze (Sequential Pipeline)

When to use: Batch analytics, report generation, and data extraction pipelines
where the data set is fixed before analysis begins.

Frameworks that exemplify this:

- CrewAI `researcher → reporting_analyst` sequential task flow[^2]
- AutoGen `WebSearchAgent → DataAnalystAgent` via SelectorGroupChat[^1]
- LangGraph `subgraph` pattern for separate retrieval and synthesis nodes

Structure:

```text
Task 1 (Retrieval Agent):
  Input: query / parameters
  Actions: fetch, save, normalize
  Output: structured_dataset (facts, not raw)

Task 2 (Analysis Agent):
  Input: structured_dataset from Task 1
  Actions: reason, synthesize, evaluate
  Output: findings report
```

Key invariant: The retrieval agent always summarizes or filters before
returning. It never returns raw content to the orchestrator.

---

### Pattern: Retrieve-and-Analyze (Iterative Investigation Loop)

When to use: Diagnosis workflows, root-cause analysis, security
investigations, and log triage where the investigation path is not known in
advance and each retrieval informs the next.

Frameworks that exemplify this:

- Anthropic Agent SDK's agentic loop: "Claude evaluates, calls tools to take
  action, receives the results, and repeats until the task is complete"[^7]
- OpenAI Agents SDK's `run()` loop: "Execute tool calls and append results →
  Switch Agent if necessary → If no new function calls, return"[^3]
- AutoGen's `handle_task` method: "generates a response → processes tool calls
  → makes another call to the model → until the response is not a tool call"[^8]

Structure:

```text
Investigation Subagent (one invocation = one iteration):
  Input: investigation_brief (objective, scope, prior_findings)
  Loop:
    ├── Query AWS CLI (retrieval tool call)
    ├── Evaluate result (inline analysis)
    └── Decide: need more data? → loop; else exit
  Output: {
    status: RESOLVED | NEEDS_ITERATION | BLOCKED,
    summary: "1-3 sentences",
    findings: [judgment1, judgment2, ...],
    artifacts_saved: [path1, path2],
    next_query_suggestion: "..." // if NEEDS_ITERATION
  }
```

Key invariant: The subagent returns structured results only and never raw log
data. This is the Subagent Return Contract established in
`docs/reports/2026-03-05-orchestrator-delegation.md`.[^5]

---

## Applied Recommendation: CloudWatch Investigation Orchestrator

### Verdict: Keep retrieval + analysis + decision in one subagent per iteration

The current design, where one subagent handles query → save → analyze → decide,
is architecturally correct. The subagent represents one iteration of the
investigation loop, and that boundary is exactly right.

### The one change that matters: enforce the Subagent Return Contract

The anti-pattern risk is not the combination of retrieval and analysis. It is
the subagent returning raw log data to the orchestrator. The orchestrator
should only receive structured investigation results.

Correct subagent return structure:

```markdown
## Investigation Result (Iteration N)

**Status:** NEEDS_ITERATION | RESOLVED | BLOCKED

**Summary:** [1-3 sentences: what was found, what it means]

**Findings:**

- [judgment 1 with brief evidence reference]
- [judgment 2 with brief evidence reference]

**Artifacts saved:**

- /path/to/cloudwatch-query-YYYYMMDD-HHMMSS.json

**Next query recommendation:** (if NEEDS_ITERATION)

- Log group: /aws/lambda/my-function
- Time range: T-2h to T-1h
- Filter pattern: "ERROR" AND "timeout"
- Rationale: Found timeout pattern in prior results suggesting upstream
  dependency issue
```

The orchestrator only reads `status` and `next_query_recommendation` to route
the next iteration. It never reads the raw log artifacts.

### When to split in future evolution

If the CloudWatch investigation system grows to include:

- Parallel multi-region log retrieval, where retrieval becomes independently
  heavy and parallelizable
- Specialized analysis models, such as anomaly detection vs. root-cause models
- Reusable retrieval capability across different investigation workflows

Then a split becomes worth considering. At that point, the retrieval subagent
would still summarize or filter before returning, and the analysis subagent
would receive structured facts, not raw logs.

---

## Summary Table: Framework Pattern Cross-Reference

- AutoGen AgentChat
  - Retrieval-analysis pattern: Separate agents
    (`WebSearch + DataAnalyst`)
  - Default granularity: One capability per agent
  - Key principle: Agents broadcast to shared context; roles prevent overlap
- CrewAI
  - Retrieval-analysis pattern: Sequential tasks
    (`researcher → reporting_analyst`)
  - Default granularity: One task per agent per pipeline stage
  - Key principle: `context` passes structured task output downstream
- OpenAI Swarm / Agents SDK
  - Retrieval-analysis pattern: Handoffs between routines
  - Default granularity: One routine equals one bounded set of steps
  - Key principle: Agent transfers when domain changes
- LangGraph
  - Retrieval-analysis pattern: Subgraph nodes with conditional edges
  - Default granularity: One node per capability; iterative loops as cycles
  - Key principle: Graph structure enforces flow; loops are first-class
- AWS Bedrock Multi-Agent
  - Retrieval-analysis pattern: Supervisor delegates to specialist
    collaborators
  - Default granularity: One domain per collaborator
  - Key principle: Minimize overlapping responsibilities
- Anthropic Agent SDK
  - Retrieval-analysis pattern: Single agent loop with tool calls
  - Default granularity: Full investigation equals one agent loop
  - Key principle: Loop continues until no tool calls; `max_turns` bounds it
- This repo (established)
  - Retrieval-analysis pattern: Goal-oriented missions, not tool operations
  - Default granularity: One mission equals one subagent invocation
  - Key principle: Data utilization rate gate; structured return contract

---

## Confidence Assessment

- Split retrieval and analysis is canonical in stateless pipelines
  - Confidence: High
  - Basis: Directly documented in AutoGen, CrewAI, and CrewAI examples
- Combined is correct for iterative investigation loops
  - Confidence: High
  - Basis: Consistent across Anthropic Agent SDK, OpenAI loop patterns, and
    this repo's own reports
- Subagent Return Contract, meaning structured results only, is the critical
  invariant
  - Confidence: High
  - Basis: Documented in this repo's reports and consistent with framework
    guidance not to pass raw data
- Data utilization rate gate is a strong decision heuristic
  - Confidence: High
  - Basis: Documented in
    `docs/reports/2026-03-03-subagent-delegation-failure-report.md` and
    consistent with AutoGen's explicit tool restriction patterns
- Model-per-capability optimization, meaning splitting for cost, is plausible
  but secondary
  - Confidence: Medium
  - Basis: Inferred from AutoGen and CrewAI `function_calling_llm` patterns;
    not directly documented for investigation loops

---

## Footnotes

[^1]:
    AutoGen `SelectorGroupChat` Web Search/Analysis example —
    `microsoft.github.io/autogen/stable/user-guide/agentchat-user-guide/selector-group-chat.html`
    — documents explicit `WebSearchAgent` (retrieval only, no calculations) and
    `DataAnalystAgent` (analysis only, no search) as the canonical multi-agent
    pattern.

[^2]:
    CrewAI canonical agents.yaml / tasks.yaml example —
    `docs.crewai.com/concepts/agents` and `docs.crewai.com/concepts/tasks` —
    separates `researcher` (tools: SerperDevTool) from `reporting_analyst`
    (no retrieval tools) as the standard project template.

[^3]:
    OpenAI Swarm README — `github.com/openai/swarm` — defines agents as
    routines with bounded steps; handoffs transfer control when domain changes.
    Replaced by OpenAI Agents SDK as the production implementation.

[^4]:
    AWS Bedrock Multi-Agent Collaboration —
    `docs.aws.amazon.com/bedrock/latest/userguide/agents-multi-agent-collaboration.html`
    — says to clearly designate the role and responsibilities of the supervisor
    and collaborator agents and to minimize overlapping responsibilities.

[^5]:
    `docs/reports/2026-03-05-orchestrator-delegation.md` — defines
    Delegation Granularity as goal-oriented missions rather than tool operations,
    and the Subagent Return Contract as structured results rather than raw
    content.

[^6]:
    `docs/reports/2026-03-03-subagent-delegation-failure-report.md` —
    defines the data utilization rate gate: "Will I use every field of the
    returned data directly in this context?" If no, delegate.

[^7]:
    Anthropic Agent SDK agent loop —
    `docs.anthropic.com/en/docs/agent-sdk/agent-loop` — says Claude evaluates the
    prompt, calls tools to take action, receives the results, and repeats until
    the task is complete.

[^8]:
    AutoGen Core `AIAgent.handle_task` —
    `microsoft.github.io/autogen/stable/user-guide/core-user-guide/design-patterns/handoffs.html`
    — implements the inner tool-call loop: generate response, process tool
    calls, generate the next response, and continue until no tool calls remain.
