---
name: aws-cli
description: >-
  AWS CLI CloudWatch Logs investigation coordinator. Use when the user asks to
  retrieve, analyze, or investigate CloudWatch Logs, debug Lambda or ECS
  issues using log data, or correlate events across AWS services.
user-invocable: true
disable-model-invocation: false
---

# AWS CLI

## Overview

This workflow skill coordinates iterative CloudWatch Logs investigation through task subagents.
The main agent initializes session state, dispatches investigation or proposal subagents,
evaluates returned summaries, and writes the final summary. The main agent never runs AWS CLI
commands and never reads raw log files.

Each investigation subagent must invoke aws-cli-log-retrieval via skill() to get the retrieval
and summary procedure. Within the provided context, the subagent decides which log groups, time
slices, filter patterns, and follow-up queries to run, then returns a structured summary with
saved artifact paths and a resolution assessment.

An investigation is considered stalled after two consecutive unresolved iterations. When that
happens, the main agent dispatches a proposal subagent to review prior summaries and artifact
paths, then suggest the next investigation methods.

## Schema

```ts
interface InvestigationContext {
  request: string;
  log_groups: readonly string[];
  profile: string;
  region: string;
  time_range: string;
  prior_summaries: readonly string[];
  prior_file_paths: readonly string[];
  proposed_methods: readonly string[];
}

interface InvestigationResult {
  summary: string;
  saved_paths: readonly string[];
  resolved: boolean;
}

interface ProposalResult {
  proposed_methods: readonly string[];
}
```

## Constraints

- Never run AWS CLI commands in the main agent context; dispatch a task subagent for each
  investigation or proposal step.
- Never read raw log file contents in the main agent context.
- Always generate one run timestamp at execution start and use
  `{session_dir}/{run_timestamp}-aws-cli/` for intermediate artifacts and
  `{session_dir}/{run_timestamp}-aws-cli-summary.md` for the final summary.
- Always verify that `run_dir` exists immediately after creation before proceeding.
- Always pass log groups, time range, profile, region, prior summaries, prior file paths,
  proposed methods, and `run_dir` to each Stage 2 subagent.
- Always instruct Stage 2 subagents to invoke aws-cli-log-retrieval via skill(), and require
  them to follow that sub-skill's output contract.
- Always require Stage 2 subagents to return a summary, saved file paths, and a resolution
  assessment.
- Always require Stage 4 subagents to return only proposed investigation methods.
- Limit the investigation loop to a maximum of 5 iterations.
- Treat the Stage 2 and Stage 4 prompt blocks as starting points and adapt them with the current
  investigation context before each dispatch.
- If all iterations finish without resolution, write a partial summary that captures findings,
  artifact paths, and remaining unknowns.

## Execution

```python
session_dir = f"~/.copilot/session-state/{session_id}/files"

initialize = stage_1_initialize(session_dir, request)
run_timestamp = initialize.run_timestamp
run_dir = initialize.run_dir
context = initialize.scope
summary_path = f"{session_dir}/{run_timestamp}-aws-cli-summary.md"

all_summaries = []
all_paths = []
prior_summaries = []
prior_file_paths = []
proposed_methods = []
context.prior_summaries = []
context.prior_file_paths = []
context.proposed_methods = []

resolved = False
iteration = 0
unresolved_streak = 0
max_iterations = 5

while not resolved and iteration < max_iterations:
    iteration += 1
    context.prior_summaries = prior_summaries
    context.prior_file_paths = prior_file_paths
    context.proposed_methods = proposed_methods

    result = stage_2_investigate(context, iteration, run_dir)
    all_summaries.append(result.summary)
    all_paths.extend(result.saved_paths)
    prior_summaries = list(all_summaries)
    prior_file_paths = list(all_paths)

    resolved, next_action, unresolved_streak = stage_3_evaluate(
        result,
        iteration,
        unresolved_streak,
    )

    if not resolved and next_action == "propose":
        proposal = stage_4_propose(all_summaries, all_paths, request)
        proposed_methods = list(proposal.proposed_methods)

stage_5_finalize(all_summaries, all_paths, summary_path, resolved)
```

### Stage 1: Initialize

- Purpose: Prepare session state, create the run directory, verify it exists, and derive the
  initial investigation scope from the request.
- Inputs: `session_dir: string`, `request: string`
- Actions:

  ```yaml
  - action: main-agent-operation
    steps:
      - Generate a run timestamp in YYYYMMDDHHMMSS format.
      - Create {session_dir}/{run_timestamp}-aws-cli/ for intermediate artifacts.
      - Verify that the created run_dir exists and is writable.
      - Parse the request to identify target log groups, time range, profile, and region.
      - Initialize prior_summaries, prior_file_paths, proposed_methods, all_summaries, and
        all_paths as empty arrays.
  ```

- Outputs: `run_timestamp: string`, `run_dir: string`, `scope: InvestigationContext`
- Guards: Proceed only after `run_dir` exists, is writable, and the initial scope is determined.
- Faults:
  - If directory creation or verification fails, abort and report the filesystem error.
  - If the request cannot be parsed into a usable investigation scope, abort and report the
    missing scope details.

### Stage 2: Investigate

- Purpose: Dispatch a task subagent to retrieve logs, analyze findings, and
  return a structured investigation result.
- Inputs: `context: InvestigationContext`, `iteration: number`, `run_dir: string`
- Actions:

  ```yaml
  - tool: task
    agent_type: "general-purpose"
    model: "claude-opus-4.6"
    prompt: |
      Invoke aws-cli-log-retrieval via skill() to obtain the retrieval and
      summary procedure, then execute the investigation within this context.
      You may decide which log groups, time slices, filter patterns, and
      follow-up queries to run based on the provided evidence.

      Original request: {context.request}
      Log groups: {context.log_groups}
      Time range: {context.time_range}
      Profile: {context.profile}
      Region: {context.region}
      Prior summaries: {context.prior_summaries}
      Prior file paths: {context.prior_file_paths}
      Proposed methods: {context.proposed_methods}
      run_dir: {run_dir}

      Return output that follows the aws-cli-log-retrieval summary contract:
      - summary: concise investigation summary only
      - saved_paths: artifact paths only
      - resolved: true or false
  ```

- Outputs: `result: InvestigationResult`, retrieval artifacts in `run_dir`
- Guards: Proceed only after the subagent returns a summary, file paths, and a resolution
  assessment tied to artifacts in `run_dir`.
- Faults:
  - If the subagent returns raw log content instead of the required structure,
    retry once with a stricter prompt and abort on repeat failure.
  - If AWS credentials are expired, keep `resolved` false and include the credential failure in
    the returned summary.
  - If one log group fails while others succeed, continue with successful retrievals and require
    the summary to note the failed group.

### Stage 3: Evaluate

- Purpose: Review the investigation result and decide whether to continue, switch to proposal,
  or finish.
- Inputs: `result: InvestigationResult`, `iteration: number`, `unresolved_streak: number`
- Actions:

  ```yaml
  - action: main-agent-evaluation
    steps:
      - Review the returned summary against the original request and prior findings.
      - If result.resolved is true, set resolved to true and next_action to "done".
      - If result.resolved is false, increment unresolved_streak.
      - If unresolved and iteration < 2, set next_action to "investigate".
      - If unresolved and iteration >= 2, set next_action to "propose".
      - Treat the investigation as stalled after two consecutive unresolved
        iterations.
  ```

- Outputs: `resolved: boolean`, `next_action: "done" | "investigate" | "propose"`,
  `unresolved_streak: number`
- Guards: Always evaluate each Stage 2 result before any new dispatch.
- Faults:
  - If the returned summary is empty or malformed, count the iteration as unresolved, refine
    the next prompt, and continue within the remaining iteration limit.

### Stage 4: Propose

- Purpose: Dispatch a task subagent to suggest the next investigation methods after the
  investigation stalls.
- Inputs: `all_summaries: ReadonlyArray<string>`, `all_paths: ReadonlyArray<string>`,
  `request: string`
- Actions:

  ```yaml
  - tool: task
    agent_type: "general-purpose"
    model: "claude-opus-4.6"
    prompt: |
      Review the unresolved CloudWatch Logs investigation and propose only the
      next investigation methods.

      Original request: {request}
      Prior summaries: {all_summaries}
      Saved file paths: {all_paths}

      Return only:
      - proposed_methods: ordered list of next investigation methods
  ```

- Outputs: `proposal: ProposalResult`
- Guards: Dispatch only when the investigation is unresolved and `iteration >= 2`.
- Faults:
  - If the proposal subagent returns no actionable methods, continue with an
    empty proposal list and let Stage 5 record the remaining unknowns.

### Stage 5: Finalize

- Purpose: Write the final summary after the loop ends.
- Inputs: `all_summaries: ReadonlyArray<string>`, `all_paths: ReadonlyArray<string>`,
  `summary_path: string`, `resolved: boolean`
- Actions:

  ```yaml
  - action: main-agent-operation
    steps:
      - Write a final summary to {summary_path}.
      - Include whether the investigation resolved, the iteration summaries,
        saved artifact paths, and any remaining unknowns.
      - If unresolved, mark the summary as partial.
  ```

- Outputs: `{session_dir}/{run_timestamp}-aws-cli-summary.md`
- Guards: Run only after the investigation loop ends.
- Faults:
  - If writing the final summary fails, abort and report the filesystem error.

## Session Files

| File                                                        | Written By | Read By |
| ----------------------------------------------------------- | ---------- | ------- |
| `{session_dir}/YYYYMMDDHHMMSS-aws-cli/`                     | Stage 1    | Stage 2 |
| `{session_dir}/YYYYMMDDHHMMSS-aws-cli/{artifact-name}.json` | Stage 2    | Stage 2 |
| `{session_dir}/YYYYMMDDHHMMSS-aws-cli-summary.md`           | Stage 5    | Caller  |

- Retrieval artifacts follow the naming pattern
  `{session_dir}/YYYYMMDDHHMMSS-aws-cli/{log-group-sanitized}-{epoch-start}-{epoch-end}.json`.

## Examples

### Happy Path

- The user asks to investigate Lambda timeout errors in `<log-group>`.
- Stage 1 creates and verifies the run directory, then parses the scope.
- Stage 2 invokes aws-cli-log-retrieval through a task subagent and returns a
  resolved summary with artifact paths.
- Stage 5 writes the final summary to the session summary path.

### Failure Path

- A first investigation returns an unresolved summary for `<log-group>`.
- A second unresolved iteration triggers the stalled-investigation rule.
- Stage 4 proposes checking a related log group and narrowing the time slice.
- The loop ends unresolved, so Stage 5 writes a partial summary with remaining
  unknowns and artifact paths.
