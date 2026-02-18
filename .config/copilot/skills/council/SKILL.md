---
name: council
description: Orchestrate a council of three diverse LLMs to answer a question through parallel response generation, anonymized peer review with ranking, and chairman synthesis. This skill should be used when seeking high-quality, comprehensive answers that benefit from multiple AI perspectives and collective deliberation.
---

# LLM Council

## Overview

This skill orchestrates a 3-stage multi-LLM deliberation workflow:

1. **Stage 1 - Parallel Response Generation**: Three diverse LLMs independently answer the same question in parallel.
2. **Stage 2 - Anonymized Peer Review**: Each LLM reviews and ranks all responses under anonymous labels, preventing model-name bias.
3. **Stage 3 - Chairman Synthesis**: A high-capability model synthesizes the best answer using all responses, evaluations, and aggregate rankings.

Use this skill for complex questions that benefit from multiple AI perspectives -- architectural trade-offs, design decisions, strategy evaluations, nuanced technical comparisons, or any question where a single model's blind spots could lead to an incomplete answer.

The skill produces an aggregate ranking table showing council consensus and a chairman-synthesized final answer that draws on the strongest elements from all responses.

## Council Configuration

| Role | Model | Provider | Purpose |
|------|-------|----------|---------|
| Council Member 1 | `claude-opus-4.6` | Anthropic | Deep reasoning and nuanced analysis |
| Council Member 2 | `gemini-3-pro-preview` | Google | Broad knowledge and alternative perspectives |
| Council Member 3 | `gpt-5.3-codex` | OpenAI | Structured thinking and code-focused insights |
| Chairman | `claude-opus-4.6` | Anthropic | Extended thinking synthesis |

## Workflow

### Stage 1: Parallel Response Generation

1. Read [references/stage1-prompt.md](references/stage1-prompt.md).
2. Inject `{user_question}` with the actual question from the user.
3. Inject `{output_filepath}` = `~/.copilot/session-state/{session-id}/files/council-stage1-{model}-{timestamp}.md` where `{timestamp}` uses format `YYYYMMDDHHMMSS`.
4. Launch 3 parallel `task()` calls:

```
task(agent_type="general-purpose", model="claude-opus-4.6", description="Council Stage 1 - Claude", prompt=<stage1-prompt with injected question and filepath>)
task(agent_type="general-purpose", model="gemini-3-pro-preview", description="Council Stage 1 - Gemini", prompt=<stage1-prompt with injected question and filepath>)
task(agent_type="general-purpose", model="gpt-5.3-codex", description="Council Stage 1 - GPT", prompt=<stage1-prompt with injected question and filepath>)
```

5. Collect responses. If fewer than 2 succeed, abort with error message: "Council quorum not met: fewer than 2 responses received." If exactly 2 succeed, continue with a degraded-mode notice appended to the final output. Note which 2 models succeeded for use in Stage 2.

### Stage 2: Anonymized Peer Review

1. Define Stage 2 preparation files:
   - `{anonymized_input_filepath}` = `~/.copilot/session-state/{session-id}/files/council-stage2-input-{timestamp}.md`
   - `{label_mapping_filepath}` = `~/.copilot/session-state/{session-id}/files/council-label-mapping-{timestamp}.json`
2. Build `{stage1_response_filepaths}` as explicit absolute filepaths for the Stage 1 responses that succeeded.
3. Read [references/stage2-prep-prompt.md](references/stage2-prep-prompt.md).
4. Inject `{stage1_response_filepaths}`, `{anonymized_input_filepath}`, and `{label_mapping_filepath}`.
5. Launch Stage 2 Prep sub-agent (main agent must not read Stage 1 contents):

```
task(agent_type="general-purpose", model="claude-sonnet-4.6", description="Council Stage 2 Prep", prompt=<stage2-prep-prompt with injected file paths>)
```

6. Verify `{anonymized_input_filepath}` and `{label_mapping_filepath}` exist. If either is missing, follow Error Handling.
7. Read [references/stage2-prompt.md](references/stage2-prompt.md).
8. Inject `{user_question}` with the original question.
9. Inject `{anonymized_input_filepath}` with the generated Stage 2 input file path.
10. Inject `{output_filepath}` = `~/.copilot/session-state/{session-id}/files/council-stage2-{model}-{timestamp}.md` for each reviewer.
11. Launch 3 parallel `task()` calls with the same anonymized input filepath for all reviewers:

```
task(agent_type="general-purpose", model="claude-opus-4.6", description="Council Stage 2 - Claude Review", prompt=<stage2-prompt with injected question and anonymized input filepath>)
task(agent_type="general-purpose", model="gemini-3-pro-preview", description="Council Stage 2 - Gemini Review", prompt=<stage2-prompt with injected question and anonymized input filepath>)
task(agent_type="general-purpose", model="gpt-5.3-codex", description="Council Stage 2 - GPT Review", prompt=<stage2-prompt with injected question and anonymized input filepath>)
```

### Ranking Aggregation

Delegate ranking aggregation to a dedicated sub-agent (do not compute inline):

1. Define `{output_filepath}` = `~/.copilot/session-state/{session-id}/files/council-aggregate-rankings-{timestamp}.md`.
2. Build `{stage2_review_filepaths}` as explicit absolute filepaths for valid Stage 2 review outputs.
3. Read [references/ranking-aggregation-prompt.md](references/ranking-aggregation-prompt.md).
4. Inject `{stage2_review_filepaths}`, `{label_mapping_filepath}`, and `{output_filepath}`.
5. Launch a `task()` to compute rankings:

```
task(agent_type="general-purpose", model="claude-sonnet-4.6", description="Council Ranking Aggregation", prompt=<ranking-aggregation-prompt with injected file paths>)
```

6. Verify the file `{output_filepath}` exists. If not, note the failure and proceed to Stage 3 without aggregate rankings.

### Stage 3: Chairman Synthesis

1. Read [references/stage3-prompt.md](references/stage3-prompt.md).
2. Prepare context variables (DO NOT read intermediate file contents):
   - `{user_question}`: the original question
   - `{stage1_response_filepaths}`: explicit absolute filepaths for successful Stage 1 responses
   - `{stage2_review_filepaths}`: explicit absolute filepaths for successful Stage 2 reviews
   - `{rankings_filepath}`: `~/.copilot/session-state/{session-id}/files/council-aggregate-rankings-{timestamp}.md`
   - `{label_mapping_filepath}`: `~/.copilot/session-state/{session-id}/files/council-label-mapping-{timestamp}.json`
   - `{output_filepath}`: `~/.copilot/session-state/{session-id}/files/council-stage3-synthesis-{timestamp}.md`
3. Launch 1 task to generate the full final report:

```
task(agent_type="general-purpose", model="claude-opus-4.6", description="Council Stage 3 - Chairman Synthesis", prompt=<stage3-prompt with injected file paths>)
```

4. If the chairman task fails, launch a fallback synthesis sub-agent using `references/fallback-synthesis-prompt.md`:

```
task(agent_type="general-purpose", model="claude-sonnet-4.6", description="Council Stage 3 - Fallback Synthesis", prompt=<fallback-synthesis-prompt with injected file paths, output_filepath set to council-stage3-fallback-{timestamp}.md>)
```

## Output Format

1. Check if the Stage 3 task succeeded.
2. If successful, read only: `~/.copilot/session-state/{session-id}/files/council-stage3-synthesis-{timestamp}.md`.
3. Present that file content to the user without modification.
4. If Stage 3 failed, run delegated fallback synthesis first, then read only: `~/.copilot/session-state/{session-id}/files/council-stage3-fallback-{timestamp}.md`.
5. The main agent must not read Stage 1, Stage 2, ranking, or label mapping files directly.


## Error Handling

| Condition | Behavior |
|-----------|----------|
| Stage 1: Fewer than 2 responses | Abort with "Council quorum not met" error |
| Stage 1: Exactly 2 responses | Continue in degraded mode; use only 2 labels (A/B); note it in final output |
| Stage 2 Prep: sub-agent failure or missing `{anonymized_input_filepath}` / `{label_mapping_filepath}` | Launch fallback synthesis sub-agent to create `council-stage3-fallback-{timestamp}.md`; main agent reads only fallback file |
| Stage 2: Fewer than 2 reviewer task successes | Continue with available evaluations; note in output |
| Stage 2: Parse failure on 1 reviewer | Skip that reviewer; compute aggregation from remaining valid rankings |
| Stage 2: All parse failures | Proceed to Stage 3 without aggregate rankings |
| Stage 3: Chairman failure, aggregation available | Launch fallback synthesis sub-agent using rankings + Stage 1 files; read only fallback file |
| Stage 3: Chairman failure, no aggregation | Launch fallback synthesis sub-agent using Stage 1 files; read only fallback file |

## Session Files

All files are saved to `~/.copilot/session-state/{session-id}/files/`:

| File | Content |
|------|---------|
| `council-stage1-claude-opus-4.6-{timestamp}.md` | Claude's Stage 1 response |
| `council-stage1-gemini-3-pro-preview-{timestamp}.md` | Gemini's Stage 1 response |
| `council-stage1-gpt-5.3-codex-{timestamp}.md` | GPT's Stage 1 response |
| `council-stage2-claude-opus-4.6-{timestamp}.md` | Claude's peer review |
| `council-stage2-gemini-3-pro-preview-{timestamp}.md` | Gemini's peer review |
| `council-stage2-gpt-5.3-codex-{timestamp}.md` | GPT's peer review |
| `council-stage2-input-{timestamp}.md` | Anonymized Stage 1 responses used by Stage 2 reviewers |
| `council-label-mapping-{timestamp}.json` | JSON mapping from response labels to model names |
| `council-aggregate-rankings-{timestamp}.md` | Aggregate ranking table |
| `council-stage3-synthesis-{timestamp}.md` | Chairman's synthesis |
| `council-stage3-fallback-{timestamp}.md` | Delegated fallback final output |

Timestamps use format `YYYYMMDDHHMMSS` (e.g., `20260218030000`). The `{session-id}` is the actual session UUID from `~/.copilot/session-state/`.

## Invocation Example

```
# Step 1: invoke the skill
skill: council

# Step 2: ask your question in the conversation
"Compare microservices vs monolith architectures for a startup"
```

Example questions well-suited for the LLM Council:
- "What are the best practices for securing a REST API?"
- "Explain the trade-offs between PostgreSQL and MongoDB for a social app"
- "How should I structure a large React application?"
