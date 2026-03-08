---
name: council
description: >
  Produce high-quality answers by synthesizing perspectives from multiple AI models
  through structured multi-stage deliberation.
  This skill should be used when seeking high-quality, comprehensive answers that benefit
  from multiple AI perspectives and collective deliberation.
user-invocable: true
disable-model-invocation: false
---

# LLM Council

## Overview

Orchestrate a 3-stage multi-LLM deliberation: parallel response generation, anonymized peer
review with ranking, and chairman synthesis. Use for complex questions where a single model's
blind spots could lead to an incomplete answer.

All stage artifacts use `{session_dir}` which resolves to
`~/.copilot/session-state/{session_id}/files/` for the current session.

## Schema

```typescript
type Response = {
  model: string;
  content: string;
  artifact_path: string;
};

type SynthesizeInput = {
  session_id: string;
  question: string;
  responses: Response[];
  reviews: Array<{
    reviewer: string;
    ranking: string[];
    artifact_path: string;
  }>;
  rankings?: string;
};
```

## Constraints

- If fewer than 2 responses are received, abort immediately.
- If only 2 of 3 responses succeed, continue with 2 responses and note the degradation in output.
- Question must be non-empty; abort with an explicit input validation error if missing.
- If anonymized input or label mapping is missing, abort immediately.
- Anonymized content must not contain model names; abort and regenerate anonymized artifacts if detected.
- If fewer than 2 valid reviews are received, continue with available reviews.
- If all review parses fail, skip Stage 4 and proceed to Stage 5 without rankings.
- Reviewer output must include a FINAL RANKING section; discard invalid reviews and continue.
- If aggregate ranking fails or the output file is missing, proceed to Stage 5 without aggregate rankings.
- Ranking table must use canonical header ordering; regenerate the table before returning if incorrect.
- If chairman synthesis fails, invoke council-fallback with available Stage 1 paths and continue.
- Synthesis output path must be absolute and session-scoped; abort with a path validation error if not.

## Execution

```python
generate_responses()
anonymize()
reviews = peer_review()
if reviews:
    aggregate_rankings()
synthesize()
```

### Stage 1: Parallel Response Generation

- Purpose: Produce independent Stage 1 responses in parallel and enforce quorum.
- Inputs: question: string
- Actions:

  ```yaml
  - tool: task
    agent_type: "general-purpose"
    model: "claude-opus-4.6"
    prompt: >
      Invoke skill council-respond with
      question={question},
      output_filepath={session_dir}/council-stage1-claude-opus-4.6-{timestamp}.md
  - tool: task
    agent_type: "general-purpose"
    model: "gemini-3-pro-preview"
    prompt: >
      Invoke skill council-respond with
      question={question},
      output_filepath={session_dir}/council-stage1-gemini-3-pro-preview-{timestamp}.md
  - tool: task
    agent_type: "general-purpose"
    model: "gpt-5.3-codex"
    prompt: >
      Invoke skill council-respond with
      question={question},
      output_filepath={session_dir}/council-stage1-gpt-5.3-codex-{timestamp}.md
  ```

- Outputs: stage1_response_paths: string[] (3 files)
- Guards: At least 2 successful responses are required.
- Faults:
  - If fewer than 2 responses succeed, abort immediately with no fallback.
  - If only 2 of 3 responses succeed, continue with 2 responses and note the degradation in output.

### Stage 2: Anonymize

- Purpose: Strip model identity and produce anonymized Stage 2 artifacts.
- Inputs: question: string, stage1_response_paths: string[]
- Actions:

  ```yaml
  - tool: task
    agent_type: "general-purpose"
    model: "claude-opus-4.6"
    prompt: >
      Invoke skill council-anonymize with
      question={question},
      response_paths={stage1_response_paths},
      output_anonymized_path={session_dir}/council-stage2-input-{timestamp}.md,
      label_map_path={session_dir}/council-label-mapping-{timestamp}.json
      Return the anonymized artifact path and label map path.
  ```

- Outputs: anonymized_input_path: string, anonymized_artifact_paths: string[], label_map_path: string
- Guards: Both anonymized input and label mapping files exist.
- Faults:
  - If anonymized input or label mapping is missing, abort immediately with no fallback.

### Stage 3: Parallel Peer Review

- Purpose: Collect independent peer reviews and rankings over anonymized responses.
- Inputs: anonymized_input_path: string
- Actions:

  ```yaml
  - tool: task
    agent_type: "general-purpose"
    model: "claude-opus-4.6"
    prompt: "Use the skill tool to invoke council-review with anonymized_artifact_path={anonymized_input_path}, output_review_path={session_dir}/council-stage3-claude-opus-4.6-{timestamp}.md"
  - tool: task
    agent_type: "general-purpose"
    model: "gemini-3-pro-preview"
    prompt: "Use the skill tool to invoke council-review with anonymized_artifact_path={anonymized_input_path}, output_review_path={session_dir}/council-stage3-gemini-3-pro-preview-{timestamp}.md"
  - tool: task
    agent_type: "general-purpose"
    model: "gpt-5.3-codex"
    prompt: "Use the skill tool to invoke council-review with anonymized_artifact_path={anonymized_input_path}, output_review_path={session_dir}/council-stage3-gpt-5.3-codex-{timestamp}.md"
  ```

- Outputs: stage3_review_paths: string[] (up to 3 files)
- Guards: Continue when at least one parseable review exists.
- Faults:
  - If fewer than 2 valid reviews are received, continue with available reviews.
  - If all review parses fail, skip Stage 4 and proceed to Stage 5 without rankings.

### Stage 4: Aggregate Rankings

- Purpose: Aggregate Stage 3 rankings into a consensus ranking table.
- Inputs: stage3_review_paths: string[], label_map_path: string
- Actions:

  ```yaml
  - tool: task
    agent_type: "general-purpose"
    model: "claude-opus-4.6"
    prompt: >
      Invoke skill council-aggregate with
      review_artifact_paths={stage3_review_paths},
      label_map_path={label_map_path},
      output_rankings_path={session_dir}/council-aggregate-rankings-{timestamp}.md
      Return the rankings file path.
  ```

- Outputs: aggregate_ranking_path: string (or skipped)
- Guards: Skip this stage when allParseFailures occurred in Stage 3.
- Faults:
  - If aggregate ranking fails or the output file is missing, proceed to Stage 5 without aggregate rankings.

### Stage 5: Synthesis

- Purpose: Produce final synthesis and invoke fallback when chairman synthesis fails.
- Inputs: question: string, anonymized_artifact_paths: string[],
  aggregate_ranking_path: string, label_map_path: string,
  stage1_response_paths: string[], stage3_review_paths: string[]
- Actions:

  ```yaml
  - tool: task
    agent_type: "general-purpose"
    model: "claude-opus-4.6"
    prompt: >
      Invoke skill council-synthesize with
      question={question},
      anonymized_artifact_paths={anonymized_artifact_paths},
      aggregate_ranking_path={aggregate_ranking_path},
      label_map_path={label_map_path},
      response_paths={stage1_response_paths},
      review_paths={stage3_review_paths},
      output_synthesis_path={session_dir}/council-stage5-synthesis-{timestamp}.md
      Include aggregate_ranking_path={aggregate_ranking_path} only when aggregate_ranking_path is available.
      Return the synthesis file path.
  ```

- Outputs: synthesis_path: string
- Guards: Final synthesis artifact exists and is presentation-ready.
- Faults:
  - If chairman synthesis fails, invoke council-fallback with question={question},
    response_paths={stage1_response_paths}, aggregate_ranking_path={aggregate_ranking_path},
    label_map_path={label_map_path},
    output_fallback_path={session_dir}/council-stage5-fallback-{timestamp}.md and continue.

Read only `council-stage5-synthesis-{timestamp}.md` and present its content to the user without modification.
The main agent must not read any other session file.

## Session Files

| File                                        | Written by | Read by          |
| ------------------------------------------- | ---------- | ---------------- |
| `council-stage1-{model}-{timestamp}.md`     | Stage 1    | Stage 2          |
| `council-stage2-input-{timestamp}.md`       | Stage 2    | Stage 3          |
| `council-label-mapping-{timestamp}.json`    | Stage 2    | Stage 4, Stage 5 |
| `council-stage3-{model}-{timestamp}.md`     | Stage 3    | Stage 4          |
| `council-aggregate-rankings-{timestamp}.md` | Stage 4    | Stage 5          |
| `council-stage5-synthesis-{timestamp}.md`   | Stage 5    | Main agent       |

## Examples

### Happy Path

- Input: { question: "What is the best approach to database indexing?" }
- Stages 1-5 all succeed; 3/3 responses, 3/3 reviews, rankings aggregated
- Output: synthesis document written; main agent reads and presents content

### Failure Path

- Input: { question: "..." }; Stage 1 returns 1/3 successful responses
- fault(responses.length < 2) => fallback: none; abort
