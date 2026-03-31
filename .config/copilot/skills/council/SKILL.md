---
name: council
description: >-
  Use when seeking high-quality answers that benefit from multiple AI model
  perspectives through structured multi-stage deliberation.
user-invocable: true
disable-model-invocation: false
---

# LLM Council

## Overview

Orchestrate a five-stage multi-LLM deliberation: parallel response generation,
anonymization, peer review, ranking aggregation, and chairman synthesis. Use this
for complex questions where one model's blind spots could produce an incomplete answer.

At execution start, generate a `YYYYMMDDHHMMSS` timestamp and derive:

- Intermediate artifacts: `{session_dir}/{timestamp}-council/` (referred to as `run_dir`)
- Final output: `{session_dir}/{timestamp}-council-synthesis.md`

`session_dir` resolves to `~/.copilot/session-state/{session_id}/files/`.
The question must be non-empty; abort with an input validation error if missing.

Read only `{session_dir}/{timestamp}-council-synthesis.md` and present it to the user
without modification. Do not read other session files.

## Input

- `session_id: string` - Current session identifier used to derive `session_dir`.
- `question: string` - Non-empty user question to send through the council workflow.

## Output

- `synthesis_path: string` - Absolute final path for the presentation-ready synthesis.
- `degraded_mode: boolean` - Whether the workflow continued with only 2 Stage 1 responses.
- `rankings_used: boolean` - Whether Stage 5 received aggregate rankings from Stage 4.

## Execution Flow

### Stage 1: Parallel Response Generation

Launch three independent Stage 1 responses in parallel with `claude-opus-4.6`,
`claude-sonnet-4.6`, and `gpt-5.4`. Each model must answer the same question without
seeing the others. This stage establishes quorum for the rest of the workflow.

task(council-respond, model=claude-opus-4.6 / claude-sonnet-4.6 / gpt-5.4):

> question={question},
> output_filepath={run_dir}/council-stage1-{model}.md

- Output: `{run_dir}/council-stage1-{model}.md` (3 files expected; read by Stage 2, 5)
- Fault: Fewer than 2 successes: abort. Exactly 2 successes: continue in degraded mode.

### Stage 2: Anonymize

Strip model identity from the Stage 1 responses and prepare the shared peer-review input.
This stage also emits the anonymized artifact paths and label mapping that later stages
need to reconnect anonymized labels to original artifacts. Abort if either artifact is
missing or if anonymized content still contains model names.

task(council-anonymize):

> question={question},
> response_paths={stage1_response_paths},
> output_anonymized_path={run_dir}/council-stage2-input.md,
> label_map_path={run_dir}/council-label-mapping.json

- Output: `{run_dir}/council-stage2-input.md`, `anonymized_artifact_paths`, `{run_dir}/council-label-mapping.json`
- Fault: Missing artifact or leaked model identity: abort.

### Stage 3: Parallel Peer Review

Ask the same three models to review the anonymized Stage 2 input in parallel. Keep only
parseable reviews that include a `FINAL RANKING` section. If fewer than 2 valid reviews are
received, continue with what is available. If all reviews fail to parse, skip Stage 4 and
send Stage 5 the anonymized artifacts without rankings.

task(council-review, model=claude-opus-4.6 / claude-sonnet-4.6 / gpt-5.4):

> anonymized_artifact_path={anonymized_input_path},
> output_review_path={run_dir}/council-stage3-{model}.md

- Output: `{run_dir}/council-stage3-{model}.md` (0-3 files; read by Stage 4, 5)
- Fault: All reviews invalid: skip Stage 4. Partial valid reviews: continue.

### Stage 4: Aggregate Rankings

Aggregate the valid Stage 3 rankings into a consensus table using the label mapping.
Run this stage only when Stage 3 produced at least one parseable review. The ranking
table must use canonical header ordering, and if the header ordering is wrong it must be
regenerated before returning. If aggregation fails or the output file is missing, continue
to Stage 5 without aggregate rankings.

task(council-aggregate):

> review_artifact_paths={stage3_review_paths},
> label_map_path={label_map_path},
> output_rankings_path={run_dir}/council-aggregate-rankings.md

- Output: `{run_dir}/council-aggregate-rankings.md` (optional; read by Stage 5)
- Fault: Missing or invalid aggregate rankings: continue without rankings.

### Stage 5: Synthesis

Produce the final chairman synthesis from the original responses, anonymized artifacts,
optional aggregate rankings, label mapping, and any valid reviews. The final synthesis
path must be absolute and session-scoped. If synthesis fails, invoke `council-fallback`
with the question, available Stage 1 response paths, optional aggregate ranking path,
label map path, and `output_fallback_path={session_dir}/{timestamp}-council-fallback.md`.
Pass `aggregate_ranking_path` only when it is available.

task(council-synthesize):

> question={question},
> anonymized_artifact_paths={anonymized_artifact_paths},
> aggregate_ranking_path={aggregate_ranking_path},
> label_map_path={label_map_path},
> response_paths={stage1_response_paths},
> review_paths={stage3_review_paths},
> output_synthesis_path={final_output}

- Output: `{session_dir}/{timestamp}-council-synthesis.md`
- Fault: On synthesis failure, invoke `council-fallback` and continue.

## Session Files

Intermediate files are saved under `{run_dir}/`. The final output is saved directly under
`{session_dir}/`.

| File                                                | Written by | Read by          |
| --------------------------------------------------- | ---------- | ---------------- |
| `{run_dir}/council-stage1-{model}.md`               | Stage 1    | Stage 2          |
| `{run_dir}/council-stage2-input.md`                 | Stage 2    | Stage 3          |
| `{run_dir}/council-label-mapping.json`              | Stage 2    | Stage 4, Stage 5 |
| `{run_dir}/council-stage3-{model}.md`               | Stage 3    | Stage 4          |
| `{run_dir}/council-aggregate-rankings.md`           | Stage 4    | Stage 5          |
| `{session_dir}/YYYYMMDDHHMMSS-council-synthesis.md` | Stage 5    | Main agent       |

## Examples

- Happy: `question: "What is the best approach to database indexing?"` -- all 5 stages succeed.
- Failure: `question: "..."` with only 1 Stage 1 response -- abort before synthesis.
