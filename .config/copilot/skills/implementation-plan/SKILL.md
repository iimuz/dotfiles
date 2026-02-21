---
name: implementation-plan
description: >
  Generate deterministic, machine-executable implementation plans for features, refactoring,
  and system changes via multi-agent parallel analysis and synthesis.
  Use when breaking down complex development tasks into AI-actionable phases.
---

# Implementation Plan Generator

## Overview

Produce fully self-contained implementation plans via multi-model deliberation: parallel requirement analysis, independent plan drafting, cross-review, conflict resolution, and final authoritative synthesis.

## Interface

```typescript
/**
 * @skill implementation-plan
 * @input  { userRequest: string; codebaseContext?: string }
 * @output { planFilepath: string }
 */

type PlanFile = { path: string; step: "step3d" | "final"; timestamp: string };
type AnalysisFile = {
  path: string;
  model: keyof ModelRoles;
  timestamp: string;
};
type DraftFile = { path: string; model: keyof ModelRoles; timestamp: string };
type ReviewFile = { path: string; model: keyof ModelRoles; timestamp: string };

type ModelRoles = {
  analyzerClaude: "claude-opus-4.6";
  analyzerGemini: "gemini-3-pro-preview";
  analyzerGpt: "gpt-5.3-codex";
  consolidator: "claude-opus-4.6";
  conflictResolver: "gpt-5.3-codex";
  insightValidator: "gemini-3-pro-preview";
  synthesizer: "gpt-5.3-codex";
};

type SessionFolder = {
  sessionId: string;
  sessionFilesDir: string;
  timestamp: string;
};

/**
 * @invariants
 * 1. SessionPathIntegrity: all outputs use `~/.copilot/session-state/{sessionId}/files/`; omitting sessionId is forbidden
 * 2. TimestampFormat:      all file timestamps match `YYYYMMDDHHMMSS`
 * 3. FinalNaming:          final plan filename matches `{purpose}-{component}-{version}.md`
 * 4. CamelCaseContracts:   all variable bindings use canonical camelCase names defined in @references/implementation-patterns.md Appendix A
 * 5. NoPeek:               caller must not read intermediate file content into main agent context
 */
```

## Operations

```typespec
op analyze(input: { userRequest: string; codebaseContext?: string; outputDir: SessionFolder }) -> AnalysisFile[] {
  // Launch 3 parallel task() calls using @references/analysis-prompt.md; inject userRequest, codebaseContext, outputFilepath per agent
  task(model: ModelRoles.analyzerClaude | ModelRoles.analyzerGemini | ModelRoles.analyzerGpt,
       prompt: @references/analysis-prompt.md,
       vars: { model, userRequest, codebaseContext, outputFilepath: outputDir.sessionFilesDir + "step1-{model}-{timestamp}.md" },
       timeout: 120, retry: { max: 1 });
  invariant: (analysisCount < 2) => abort("Analysis quorum not met: fewer than 2 analyses received");
  invariant: (analysisCount == 2) => warn("Degraded mode: only 2/3 analyses received; note in final output");
}

op draftPlans(input: { analyses: AnalysisFile[]; outputDir: SessionFolder }) -> DraftFile[] {
  // Launch 3 parallel task() calls; each agent reads all step1-*-{timestamp}.md and generates plan per @references/template.md
  task(model: ModelRoles.analyzerClaude | ModelRoles.analyzerGemini | ModelRoles.analyzerGpt,
       prompt: "Read all step1-*-{timestamp}.md in sessionFilesDir; synthesize a complete implementation plan following @references/template.md structure",
       vars: { sessionFilesDir: outputDir.sessionFilesDir, timestamp: outputDir.timestamp });
  invariant: (draftCount < 2) => abort("Draft quorum not met; restart step 2A with adjusted prompt");
}

op crossReview(input: { drafts: DraftFile[]; outputDir: SessionFolder }) -> ReviewFile[] {
  // Launch 3 parallel task() calls; each agent reads all step2-*-plan-draft-{timestamp}.md
  task(model: ModelRoles.analyzerClaude | ModelRoles.analyzerGemini | ModelRoles.analyzerGpt,
       prompt: "Read all step2-*-plan-draft-{timestamp}.md in sessionFilesDir; identify gaps, conflicts, and best practices across all drafts",
       vars: { sessionFilesDir: outputDir.sessionFilesDir, timestamp: outputDir.timestamp });
  invariant: (reviewSuccessCount == 0) => abort("All reviewers failed; restart step 2B with adjusted prompts");
  invariant: (parseFailures == 1)       => passthrough("Skip failed reviewer; annotate in step 3A consolidation");
}

op aggregateConsensus(input: { reviews: ReviewFile[]; outputDir: SessionFolder }) -> PlanFile {
  // Single agent reads all step2-*-review-{timestamp}.md; extracts shared insights and lists conflicts
  task(model: ModelRoles.consolidator,
       prompt: "Read all step2-*-review-{timestamp}.md in sessionFilesDir; extract consensus insights and enumerate distinct conflicts for step 3B resolution",
       vars: { sessionFilesDir: outputDir.sessionFilesDir, timestamp: outputDir.timestamp });
  invariant: (stageFailed) => passthrough("Forward available review outputs directly to synthesize with fallback notice");
}

op resolveConflicts(input: { consensus: PlanFile; outputDir: SessionFolder }) -> PlanFile {
  // Single agent reads step3a-consensus-{timestamp}.md; resolves all conflicts with evidence-based analysis
  task(model: ModelRoles.conflictResolver,
       prompt: "Read step3a-consensus-{timestamp}.md in sessionFilesDir; resolve each conflict using evidence-based analysis in a single pass",
       vars: { sessionFilesDir: outputDir.sessionFilesDir, timestamp: outputDir.timestamp });
  invariant: (conflictCount == 0) => skip("No conflicts identified; proceed directly to synthesize");
}

op validateInsights(input: { drafts: DraftFile[]; reviews: ReviewFile[]; outputDir: SessionFolder }) -> PlanFile {
  // Single agent reads step2-*-plan-draft and step2-*-review files; assesses unique model insights for feasibility
  task(model: ModelRoles.insightValidator,
       prompt: "Read all step2-*-plan-draft-{timestamp}.md and step2-*-review-{timestamp}.md in sessionFilesDir; assess model-specific unique insights for feasibility and value",
       vars: { sessionFilesDir: outputDir.sessionFilesDir, timestamp: outputDir.timestamp });
  invariant: (stageFailed) => passthrough("Forward available insight outputs to synthesize with fallback notice");
}

op synthesize(input: { userRequest: string; outputFilepath: string; outputDir: SessionFolder }) -> PlanFile {
  // Single agent self-discovers all step2/step3 files; generates final authoritative plan per @references/template.md
  task(model: ModelRoles.synthesizer,
       prompt: @references/synthesis-prompt.md,
       vars: { userRequest, sessionId: outputDir.sessionId, sessionFilesDir: outputDir.sessionFilesDir, outputFilepath },
       timeout: 300, retry: { max: 1 });
  invariant: (synthesisFailed) => fallback("Present highest-quality step 2A draft as fallback with notice");
}
```

## Execution

```text
analyze -> draftPlans -> crossReview -> [aggregateConsensus + validateInsights] -> resolveConflicts -> synthesize
```

`+` denotes parallel execution. Return `synthesize` output `PlanFile.path` to caller. Do NOT read intermediate file content into main agent context.

See [`references/implementation-patterns.md`](references/implementation-patterns.md) for session-path invariants and variable binding contracts (Appendix A).

## Reference Materials

- [`references/template.md`](references/template.md) - Mandatory plan output template structure
- [`references/analysis-prompt.md`](references/analysis-prompt.md) - Step 1 multi-perspective analysis prompt
- [`references/synthesis-prompt.md`](references/synthesis-prompt.md) - Step 3D final synthesis prompt
- [`references/implementation-patterns.md`](references/implementation-patterns.md) - Session-path invariants and variable binding contracts (Appendix A)
- [`references/examples.md`](references/examples.md) - Complete plan examples for various scenarios
