---
name: council
description: >
  Produce high-quality answers by synthesizing perspectives from multiple AI models
  through structured multi-stage deliberation.
  This skill should be used when seeking high-quality, comprehensive answers that benefit
  from multiple AI perspectives and collective deliberation.
user-invocable: false
disable-model-invocation: false
---

# LLM Council

## Overview

Orchestrate a 3-stage multi-LLM deliberation: parallel response generation, anonymized peer
review with ranking, and chairman synthesis. Use for complex questions where a single model's
blind spots could lead to an incomplete answer.

## Interface

```typescript
/**
 * @skill council
 * @input  { question: string }
 * @output { synthesis: string }
 */

type Response = { model: string; content: string; filepath: string };
type Review = { reviewer: string; ranking: string[]; filepath: string };
type LabelMapping = Record<string, string>; // "Response A/B/C" -> model name
type LabeledContent = string; // anonymized concatenated responses
type RankingTable = string; // rendered markdown ranking table filepath
type Draft = string; // in-progress synthesis text

type ModelRoles = {
  Member1: "claude-opus-4.6"; // deep reasoning and nuanced analysis
  Member2: "gemini-3-pro-preview"; // broad knowledge and alternative perspectives
  Member3: "gpt-5.3-codex"; // structured thinking and code-focused insights
  Chairman: "claude-opus-4.6"; // extended thinking synthesis
  Prep: "claude-sonnet-4.6"; // anonymization and ranking aggregation
};

type SessionFiles = {
  stage1: "council-stage1-<model>-<timestamp>.md"; // Stage 1 responses (3 files)
  stage2: "council-stage2-<model>-<timestamp>.md"; // Stage 2 reviews (3 files)
  stage2_input: "council-stage2-input-<timestamp>.md"; // anonymized Stage 1 content
  label_map: "council-label-mapping-<timestamp>.json"; // label → model mapping
  rankings: "council-aggregate-rankings-<timestamp>.md"; // aggregate ranking table
  synthesis: "council-stage3-synthesis-<timestamp>.md"; // chairman synthesis
  fallback: "council-stage3-fallback-<timestamp>.md"; // fallback final output
  // All files saved under: ~/.copilot/session-state/{session-id}/files/
  // Timestamps format: YYYYMMDDHHMMSS
};

/**
 * @invariants
 * 1. No_Peeking:           main agent must not read Stage 1, Stage 2, anonymized input
 *                          (stage2_input), ranking, or label mapping files directly;
 *                          read only synthesis/fallback output
 * 2. Filepath_Explicit:    all inter-stage file paths are absolute and fully qualified
 * 3. Semantic_Contract:    observable behavior (quorum, degraded mode, anonymization,
 *                          ranking grammar, fallback routing) is preserved across all stages
 */
```

## Operations

```typespec
op generate_responses(session_id: string, question: string) -> Response[] {
  // Three parallel task() calls, one per model role
  task(agent_type: "general-purpose",
       skill: "council-respond",
       payload: { session_id: session_id, question: question,
                  model: ModelRoles.Member1,
                  output_filepath: SessionFiles.stage1<Member1> });
  task(agent_type: "general-purpose",
       skill: "council-respond",
       payload: { session_id: session_id, question: question,
                  model: ModelRoles.Member2,
                  output_filepath: SessionFiles.stage1<Member2> });
  task(agent_type: "general-purpose",
       skill: "council-respond",
       payload: { session_id: session_id, question: question,
                  model: ModelRoles.Member3,
                  output_filepath: SessionFiles.stage1<Member3> });
  invariant: (responses.length < 2)  => abort("Council quorum not met: fewer than 2 responses received");
  invariant: (responses.length == 2) => warn("Degraded mode: 2/3 responses available; note in final output");
}

op anonymize(session_id: string, question: string, responses: Response[]) -> { labeled: LabeledContent; mapping: LabelMapping } {
  // Sequential task() call; reads stage1_response_paths, writes stage2_input and label_map
  task(agent_type: "general-purpose",
       skill: "council-anonymize",
       payload: { session_id: session_id,
                  model: ModelRoles.Prep,
                  stage1_response_paths: responses.map(r => r.filepath),
                  output_anonymized_path: SessionFiles.stage2_input,
                  label_map_path: SessionFiles.label_map });
  invariant: (anonymizedInputMissing || labelMappingMissing)
    => fallback(task(agent_type: "general-purpose",
                     skill: "council-fallback",
                     payload: { session_id: session_id, question: question,
                                model: ModelRoles.Prep,
                                stage1_response_paths: responses.map(r => r.filepath),
                                output_fallback_path: SessionFiles.fallback }));
}

op peer_review(session_id: string, question: string, anonymized_artifact_path: string) -> Review[] {
  // Three parallel task() calls, one per model role; all read same anonymized_artifact_path
  task(agent_type: "general-purpose",
       skill: "council-review",
       payload: { session_id: session_id, question: question,
                  model: ModelRoles.Member1,
                  anonymized_artifact_path: anonymized_artifact_path,
                  output_review_path: SessionFiles.stage2<Member1> });
  task(agent_type: "general-purpose",
       skill: "council-review",
       payload: { session_id: session_id, question: question,
                  model: ModelRoles.Member2,
                  anonymized_artifact_path: anonymized_artifact_path,
                  output_review_path: SessionFiles.stage2<Member2> });
  task(agent_type: "general-purpose",
       skill: "council-review",
       payload: { session_id: session_id, question: question,
                  model: ModelRoles.Member3,
                  anonymized_artifact_path: anonymized_artifact_path,
                  output_review_path: SessionFiles.stage2<Member3> });
  invariant: (validReviews < 2)    => warn("Reduced review coverage; continue with available");
  invariant: (oneParseFailure)     => skip_reviewer("omit failed reviewer from aggregation");
  invariant: (allParseFailures)    => passthrough("proceed to synthesize without rankings");
}

op aggregate_rankings(session_id: string, reviews: Review[], label_map_path: string) -> RankingTable {
  // Sequential task() call; reads stage2_review_paths and label_map_path, writes rankings
  task(agent_type: "general-purpose",
       skill: "council-aggregate",
       payload: { session_id: session_id,
                  model: ModelRoles.Prep,
                  review_artifact_paths: reviews.map(r => r.filepath),
                  label_map_path: label_map_path,
                  output_rankings_path: SessionFiles.rankings });
  invariant: (aggregateFails || outputFileMissing)
    => passthrough("proceed to synthesize without aggregate rankings");
}

op synthesize(
  session_id: string,
  question:   string,
  responses:  Response[],
  reviews:    Review[],
  rankings?:  RankingTable
) -> string {
  // Sequential task() call; pass only explicit filepaths — do NOT read intermediate files
  task(agent_type: "general-purpose",
       skill: "council-synthesize",
       payload: { session_id: session_id, question: question,
                  model: ModelRoles.Chairman,
                  anonymized_artifact_paths: [SessionFiles.stage2_input],
                  stage1_response_paths: responses.map(r => r.filepath),
                  stage2_review_paths: reviews.map(r => r.filepath),
                  aggregate_ranking_path: SessionFiles.rankings,
                  label_map_path: SessionFiles.label_map,
                  output_synthesis_path: SessionFiles.synthesis });
  invariant: (chairmanFails)
    => fallback(task(agent_type: "general-purpose",
                     skill: "council-fallback",
                     payload: { session_id: session_id, question: question,
                                model: ModelRoles.Prep,
                                stage1_response_paths: responses.map(r => r.filepath),
                                aggregate_ranking_path: SessionFiles.rankings,
                                label_map_path: SessionFiles.label_map,
                                output_fallback_path: SessionFiles.fallback }));
}
```

## Execution

```text
generate_responses -> anonymize -> peer_review -> aggregate_rankings -> synthesize
```

Read only `SessionFiles.synthesis` (or `SessionFiles.fallback` if chairman failed) and present
its content to the user without modification. The main agent must not read any other session file.
