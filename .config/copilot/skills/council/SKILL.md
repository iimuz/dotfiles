---
name: council
description: >
  Produce high-quality answers by synthesizing perspectives from multiple AI models
  through structured multi-stage deliberation.
  This skill should be used when seeking high-quality, comprehensive answers that benefit
  from multiple AI perspectives and collective deliberation.
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
op generate_responses(question: string) -> Response[] {
  // Launch 3 parallel task() calls with @references/stage1-prompt.md
  // output_filepath: SessionFiles.stage1 per model with current timestamp
  task(model: ModelRoles.Member1 | ModelRoles.Member2 | ModelRoles.Member3,
       prompt: @references/stage1-prompt.md,
       vars: { question: question, output_filepath: output_filepath });
  invariant: (responses.length < 2)  => abort("Council quorum not met: fewer than 2 responses received");
  invariant: (responses.length == 2) => warn("Degraded mode: 2/3 responses available; note in final output");
}

op anonymize(responses: Response[]) -> { labeled: LabeledContent; mapping: LabelMapping } {
  // Launch 1 task() with @references/stage2-prep-prompt.md
  // Derive: stage1_response_filepaths = responses.map(r => r.filepath)
  // Generate: anonymized_input_filepath = SessionFiles.stage2_input, label_mapping_filepath = SessionFiles.label_map
  task(model: ModelRoles.Prep, prompt: @references/stage2-prep-prompt.md,
       vars: { stage1_response_filepaths: stage1_response_filepaths, anonymized_input_filepath: anonymized_input_filepath, label_mapping_filepath: label_mapping_filepath });
  invariant: (anonymizedInputMissing || labelMappingMissing)
    // rankings_filepath and label_mapping_filepath are not yet available at this stage (produced later)
    => fallback(task(model: ModelRoles.Prep, prompt: @references/fallback-synthesis-prompt.md,
                     vars: { question: question, stage1_response_filepaths: stage1_response_filepaths, output_filepath: output_filepath }));
}

op peer_review(question: string, labeled: LabeledContent) -> Review[] {
  // Launch 3 parallel task() calls with @references/stage2-prompt.md
  // all reviewers read the same anonymized_input_filepath
  task(model: ModelRoles.Member1 | ModelRoles.Member2 | ModelRoles.Member3,
       prompt: @references/stage2-prompt.md,
       vars: { question: question, anonymized_input_filepath: anonymized_input_filepath, output_filepath: output_filepath });
  invariant: (validReviews < 2)    => warn("Reduced review coverage; continue with available");
  invariant: (oneParseFailure)     => skip_reviewer("omit failed reviewer from aggregation");
  invariant: (allParseFailures)    => passthrough("proceed to synthesize without rankings");
}

op aggregate_rankings(reviews: Review[], mapping: LabelMapping) -> RankingTable {
  // Launch 1 task() with @references/ranking-aggregation-prompt.md
  // Derive: stage2_review_filepaths = reviews.map(r => r.filepath)
  // Derive: label_mapping_filepath = mapping.filepath (from SessionFiles.label_map)
  // Generate: output_filepath = SessionFiles.rankings
  task(model: ModelRoles.Prep, prompt: @references/ranking-aggregation-prompt.md,
       vars: { stage2_review_filepaths: stage2_review_filepaths, label_mapping_filepath: label_mapping_filepath, output_filepath: output_filepath });
  invariant: (aggregateFails || outputFileMissing)
    => passthrough("proceed to synthesize without aggregate rankings");
}

op synthesize(
  question:  string,
  responses: Response[],
  reviews:   Review[],
  rankings?: RankingTable
) -> string {
  // Launch 1 task() with @references/stage3-prompt.md
  // DO NOT read intermediate files; pass only explicit filepaths
  task(model: ModelRoles.Chairman, prompt: @references/stage3-prompt.md,
       vars: { question: question, stage1_response_filepaths: stage1_response_filepaths, stage2_review_filepaths: stage2_review_filepaths, rankings_filepath: rankings_filepath, label_mapping_filepath: label_mapping_filepath, output_filepath: output_filepath });
  invariant: (chairmanFails)
    => fallback(task(model: ModelRoles.Prep, prompt: @references/fallback-synthesis-prompt.md,
                     vars: { question: question, stage1_response_filepaths: stage1_response_filepaths, rankings_filepath: rankings_filepath, label_mapping_filepath: label_mapping_filepath, output_filepath: output_filepath }));
}
```

## Execution

```text
generate_responses -> anonymize -> peer_review -> aggregate_rankings -> synthesize
```

Read only `SessionFiles.synthesis` (or `SessionFiles.fallback` if chairman failed) and present
its content to the user without modification. The main agent must not read any other session file.
