---
name: council-respond
description: >
  Generate a single independent council member response to a question.
  This skill should be used as the Stage 1 sub-skill in the LLM Council pipeline to produce
  one model's authoritative analysis without awareness of other council members.
user-invocable: false
disable-model-invocation: true
---

# Council Respond

## Overview

Wrap the Stage 1 council response generation stage: analyze the question independently, structure a
300–600 word response, and save it to a specified output filepath.

## Interface

```typescript
/**
 * @skill council-respond
 * @input  { session_id: string; question: string; model: string; output_filepath: string }
 * @output { saved_filepath: string }
 */

type AnalysisOutput = {
  reasoning: string;
  conclusion: string;
  confidence: "high" | "medium" | "low";
};

type InputContext = {
  session_id: string; // unique identifier for this council session
  question: string; // the question to answer
  model: string; // model name assigned to this council member
  output_filepath: string; // absolute path for saving the response
};

/**
 * @invariants
 * 1. Zero_Verbosity:      no imperative step text in op bodies
 * 2. Signature_Integrity: all ops fully typed
 * 3. Independence:        response must not reference other AI models or council processes
 */
```

## Operations

```typespec
op analyze_question(question: string) -> AnalysisOutput {
  // Produce independent reasoning and conclusion; declare assumptions if question is ambiguous
  invariant: (questionAmbiguous) => state_assumptions_explicitly;
  invariant: (domainOutsideExpertise) => declare_limitation;
}

op structure_response(analysis: AnalysisOutput) -> string {
  // Format analysis into a prose response between 300 and 600 words
  invariant: (conclusionUnsupported) => add_caveats;
  invariant: (otherModelsReferenced) => abort("Do not reference other AI models or council processes");
  invariant: (wordCount < 300 || wordCount > 600) => revise_length;
}

op save_response(content: string, output_filepath: string) -> void {
  // Use the create tool to write content to output_filepath
  invariant: (fileAlreadyExists) => abort("Output file already exists; use unique filepath");
}
```

## Execution

```text
analyze_question -> structure_response -> save_response
```

Execute as an expert council member providing an independent, authoritative opinion.
Use `InputContext.output_filepath` as the destination for `save_response`.
Return the saved filepath upon completion.

## Input Context

Role: You are an expert council member providing an independent, authoritative opinion.

Question: {{question}}
Output filepath: {{output_filepath}}
