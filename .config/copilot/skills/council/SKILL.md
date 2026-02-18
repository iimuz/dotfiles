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

1. Assign anonymous labels deterministically (alphabetical by model name) for the responses that succeeded in Stage 1:
   - Full council (3 responses): Response A = `claude-opus-4.6`, Response B = `gemini-3-pro-preview`, Response C = `gpt-5.3-codex`
   - Degraded mode (2 responses): assign labels A and B only in alphabetical order; omit C. Adjust all Stage 2 instructions and ranking format to use only 2 labels.
2. Read [references/stage2-prompt.md](references/stage2-prompt.md).
3. Inject `{user_question}` with the original question.
4. Inject `{anonymized_responses}` as inline content with this structure (include only available responses):

```
**Response A:**
{content of claude-opus-4.6 response}

**Response B:**
{content of gemini-3-pro-preview response}

**Response C:**
{content of gpt-5.3-codex response}
```

5. Inject `{output_filepath}` = `~/.copilot/session-state/{session-id}/files/council-stage2-{model}-{timestamp}.md` for each reviewer.
6. Launch 3 parallel `task()` calls with the SAME anonymized prompt content for all reviewers:

```
task(agent_type="general-purpose", model="claude-opus-4.6", description="Council Stage 2 - Claude Review", prompt=<stage2-prompt with injected content>)
task(agent_type="general-purpose", model="gemini-3-pro-preview", description="Council Stage 2 - Gemini Review", prompt=<stage2-prompt with injected content>)
task(agent_type="general-purpose", model="gpt-5.3-codex", description="Council Stage 2 - GPT Review", prompt=<stage2-prompt with injected content>)
```

### Ranking Aggregation

Compute ranking aggregation inline (no subagent needed) between Stage 2 and Stage 3:

1. Parse the `FINAL RANKING:` section from each Stage 2 output.
2. Extract ordered labels: 1st place = position 1, 2nd place = position 2, 3rd place = position 3.
3. For each Response label, sum all positions across valid rankings.
4. Compute average: `total_positions / number_of_valid_rankings` (lower average = better).
5. Sort by average ascending to determine the winner.
6. De-anonymize: map labels back to models using the assignment recorded in Stage 2 Step 1 (the alphabetical assignment of whichever models succeeded in Stage 1).
7. Tie-break: if multiple responses have the same average position, the response ranked 1st by more individual reviewers wins. If still tied, the chairman resolves in Stage 3.

**Example aggregation:**

- Claude reviewer: Response B = 1st, Response A = 2nd, Response C = 3rd
- Gemini reviewer: Response A = 1st, Response C = 2nd, Response B = 3rd
- GPT reviewer: Response B = 1st, Response A = 2nd, Response C = 3rd

Results:

- Response A positions: [2, 1, 2] -> average = 1.67
- Response B positions: [1, 3, 1] -> average = 1.67 (tie -> Response B wins: 2 first-place votes vs 1)
- Response C positions: [3, 2, 3] -> average = 2.67

Save the aggregate ranking table to `~/.copilot/session-state/{session-id}/files/council-aggregate-rankings-{timestamp}.md`.

### Stage 3: Chairman Synthesis

1. Read [references/stage3-prompt.md](references/stage3-prompt.md).
2. Inject all context into the prompt:
   - `{user_question}`: the original question
   - `{stage1_responses}`: all Stage 1 responses with model attribution (de-anonymized)
   - `{stage2_evaluations}`: all Stage 2 evaluations with reviewer model names
   - `{aggregate_rankings}`: markdown table of rankings with average positions
   - `{output_filepath}`: `~/.copilot/session-state/{session-id}/files/council-stage3-synthesis-{timestamp}.md`
3. Launch 1 task:

```
task(agent_type="general-purpose", model="claude-opus-4.6", description="Council Stage 3 - Chairman Synthesis", prompt=<stage3-prompt with all injected context>)
```

4. If the chairman task fails, present the top-ranked Stage 1 response as a fallback with a note explaining the chairman synthesis was unavailable.

## Output Format

Present results to the user in this structure:

```
## Council Verdict: Aggregate Rankings

| Rank | Model | Average Position |
|------|-------|-----------------|
| 1    | ...   | ...             |
| 2    | ...   | ...             |
| 3    | ...   | ...             |

## Chairman's Synthesis
{synthesis content}

---
<details>
<summary>Stage 1: Individual Responses</summary>

### claude-opus-4.6
{response}

### gemini-3-pro-preview
{response}

### gpt-5.3-codex
{response}

</details>

<details>
<summary>Stage 2: Peer Evaluations</summary>

### Review by claude-opus-4.6
{evaluation and ranking}

### Review by gemini-3-pro-preview
{evaluation and ranking}

### Review by gpt-5.3-codex
{evaluation and ranking}

</details>
```

## Error Handling

| Condition | Behavior |
|-----------|----------|
| Stage 1: Fewer than 2 responses | Abort with "Council quorum not met" error |
| Stage 1: Exactly 2 responses | Continue in degraded mode; use only 2 labels (A/B); note it in final output |
| Stage 2: Fewer than 2 reviewer task successes | Continue with available evaluations; note in output |
| Stage 2: Parse failure on 1 reviewer | Skip that reviewer; compute aggregation from remaining valid rankings |
| Stage 2: All parse failures | Pass raw evaluations to chairman without aggregation table |
| Stage 3: Chairman failure, aggregation available | Present the top-ranked Stage 1 response with fallback notice |
| Stage 3: Chairman failure, no aggregation | Present all Stage 1 responses with fallback notice |

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
| `council-aggregate-rankings-{timestamp}.md` | Aggregate ranking table |
| `council-stage3-synthesis-{timestamp}.md` | Chairman's synthesis |

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
