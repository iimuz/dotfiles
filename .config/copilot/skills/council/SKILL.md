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

## Role

Orchestrate a 3-stage multi-LLM deliberation: parallel response generation, anonymized peer
review with ranking, and chairman synthesis. Use for complex questions where a single model's
blind spots could lead to an incomplete answer.

## Interface

```typescript
/**
 * @skill council
 * @input  { question: string }
 * @output { synthesis: string }
 *
 * @param question  The question for council deliberation (required)
 * @returns synthesis  Presentation-ready council verdict and synthesis content
 */

// Types: Response, Review, LabelMapping, RankingTable, Draft

type ModelRoles = {
  Member1: "claude-opus-4.6"; // deep reasoning and nuanced analysis
  Member2: "gemini-3-pro-preview"; // broad knowledge and alternative perspectives
  Member3: "gpt-5.3-codex"; // structured thinking and code-focused insights
  Chairman: "claude-opus-4.6"; // extended thinking synthesis
  Prep: "claude-sonnet-4.6"; // anonymization and ranking aggregation
};

type SessionFiles = {
  stage1: "council-stage1-<model>-<timestamp>.md"; // Stage 1 responses (3 files)
  stage2_input: "council-stage2-input-<timestamp>.md"; // anonymized Stage 1 content
  label_map: "council-label-mapping-<timestamp>.json"; // label → model mapping
  stage3: "council-stage3-<model>-<timestamp>.md"; // Stage 3 peer reviews (3 files)
  rankings: "council-aggregate-rankings-<timestamp>.md"; // aggregate ranking table
  synthesis: "council-stage5-synthesis-<timestamp>.md"; // chairman synthesis
  // All files saved under: ~/.copilot/session-state/{session-id}/files/
  // Timestamps format: YYYYMMDDHHMMSS
};

/**
 * @invariants
 * - invariant: (mainAgentReadsIntermediateFile) => abort("Main agent must not read Stage 1, Stage 2, anonymized input, ranking, or label mapping files directly; read only synthesis/fallback output");
 * - invariant: (!pathIsAbsoluteAndFullyQualified) => abort("All inter-stage file paths must be absolute and fully qualified");
 * - invariant: (observableBehaviorViolated) => abort("Observable behavior must be preserved: quorum, degraded mode, anonymization, ranking grammar, fallback routing");
 */
```

## Operations

```typespec
op generate_responses(session_id: string, question: string) -> Response[] {
  // Three parallel task() calls, one per model role (see Execution § Stage 1)
  invariant: (responses.length < 2)  => abort("Council quorum not met: fewer than 2 responses received");
  invariant: (responses.length == 2) => warn("Degraded mode: 2/3 responses available; note in final output");
}

op anonymize(session_id: string, question: string, responses: Response[]) -> { labeled: LabeledContent; mapping: LabelMapping } {
  // Sequential task() call (see Execution § Stage 2)
  invariant: (anonymizedInputMissing || labelMappingMissing) => abort("anonymization artifacts missing; cannot proceed to peer review");
}

op peer_review(session_id: string, question: string, anonymized_artifact_path: string) -> Review[] {
  // Three parallel task() calls (see Execution § Stage 3)
  invariant: (validReviews < 2)    => warn("Reduced review coverage; continue with available");
  invariant: (oneParseFailure)     => warn("Reviewer skipped: omit failed reviewer from aggregation");
  invariant: (allParseFailures)    => warn("proceed to synthesize without rankings");
}

op aggregate_rankings(session_id: string, reviews: Review[], label_map_path: string) -> RankingTable {
  // Sequential task() call (see Execution § Stage 4)
  invariant: (aggregateFails || outputFileMissing) => warn("proceed to synthesize without aggregate rankings");
}

op synthesize(
  session_id: string,
  question:   string,
  responses:  Response[],
  reviews:    Review[],
  rankings?:  RankingTable
) -> string {
  // Sequential task() call (see Execution § Stage 5)
  invariant: (chairmanFails) => abort("chairman synthesis failed; cannot produce final output");
}
```

## Execution

```text
generate_responses -> anonymize -> peer_review -> aggregate_rankings -> synthesize
```

| dependent          | prerequisite       | description                                          |
| ------------------ | ------------------ | ---------------------------------------------------- |
| _(column key)_     | _(column key)_     | _(dependent requires prerequisite first)_            |
| anonymize          | generate_responses | anonymize consumes Stage 1 response files            |
| peer_review        | anonymize          | peer_review reads anonymized artifact                |
| aggregate_rankings | peer_review        | aggregate_rankings consumes Stage 2 review files     |
| synthesize         | aggregate_rankings | synthesize consumes rankings and all prior artifacts |

Resolve `session_dir = ~/.copilot/session-state/{session_id}/files/` and generate a `timestamp`
(YYYYMMDDHHMMSS) before starting.

### Stage 1: Parallel Response Generation

Launch 3 sub-skill calls in parallel — one per model role:

```text
task(agent_type: "general-purpose", model: "claude-opus-4.6",      prompt: "Use the skill tool to invoke 'council-respond' with input: { session_id, question, model: 'claude-opus-4.6', output_filepath: '{session_dir}/council-stage1-claude-opus-4.6-{timestamp}.md' }")
task(agent_type: "general-purpose", model: "gemini-3-pro-preview", prompt: "Use the skill tool to invoke 'council-respond' with input: { session_id, question, model: 'gemini-3-pro-preview', output_filepath: '{session_dir}/council-stage1-gemini-3-pro-preview-{timestamp}.md' }")
task(agent_type: "general-purpose", model: "gpt-5.3-codex",        prompt: "Use the skill tool to invoke 'council-respond' with input: { session_id, question, model: 'gpt-5.3-codex', output_filepath: '{session_dir}/council-stage1-gpt-5.3-codex-{timestamp}.md' }")
```

Fault tolerance: require at least 2 of 3 to succeed; abort if fewer.

### Stage 2: Anonymize

```text
task(agent_type: "general-purpose", model: "claude-sonnet-4.6", prompt: "Use the skill tool to invoke 'council-anonymize' with input: { session_id, question, model: 'claude-sonnet-4.6', stage1_response_paths: [<stage 1 output paths>], output_anonymized_path: '{session_dir}/council-stage2-input-{timestamp}.md', label_map_path: '{session_dir}/council-label-mapping-{timestamp}.json' }")
```

Fault: anonymizedInputMissing || labelMappingMissing → abort.

### Stage 3: Parallel Peer Review

```text
task(agent_type: "general-purpose", model: "claude-opus-4.6",      prompt: "Use the skill tool to invoke 'council-review' with input: { session_id, question, model: 'claude-opus-4.6', anonymized_artifact_path: '<stage2_input_path>', output_review_path: '{session_dir}/council-stage3-claude-opus-4.6-{timestamp}.md' }")
task(agent_type: "general-purpose", model: "gemini-3-pro-preview", prompt: "Use the skill tool to invoke 'council-review' with input: { session_id, question, model: 'gemini-3-pro-preview', anonymized_artifact_path: '<stage2_input_path>', output_review_path: '{session_dir}/council-stage3-gemini-3-pro-preview-{timestamp}.md' }")
task(agent_type: "general-purpose", model: "gpt-5.3-codex",        prompt: "Use the skill tool to invoke 'council-review' with input: { session_id, question, model: 'gpt-5.3-codex', anonymized_artifact_path: '<stage2_input_path>', output_review_path: '{session_dir}/council-stage3-gpt-5.3-codex-{timestamp}.md' }")
```

### Stage 4: Aggregate Rankings

```text
task(agent_type: "general-purpose", model: "claude-sonnet-4.6", prompt: "Use the skill tool to invoke 'council-aggregate' with input: { session_id, model: 'claude-sonnet-4.6', review_artifact_paths: [<stage 3 output paths>], label_map_path: '<label_map_path>', output_rankings_path: '{session_dir}/council-aggregate-rankings-{timestamp}.md' }")
```

Fault: aggregateFails || outputFileMissing → warn, proceed to Stage 5 without rankings.

### Stage 5: Synthesis

```text
task(agent_type: "general-purpose", model: "claude-opus-4.6", prompt: "Use the skill tool to invoke 'council-synthesize' with input: { session_id, question, model: 'claude-opus-4.6', anonymized_artifact_paths: ['<stage2_input_path>'], stage1_response_paths: [<stage 1 paths>], stage3_review_paths: [<stage 3 paths>], aggregate_ranking_path: '<rankings_path>', label_map_path: '<label_map_path>', output_synthesis_path: '{session_dir}/council-stage5-synthesis-{timestamp}.md' }")
```

Fault: chairmanFails → abort("chairman synthesis failed; cannot produce final output").

Read only `SessionFiles.synthesis` and present its content to the user without modification.
The main agent must not read any other session file.
