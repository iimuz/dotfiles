---
name: council-respond
description: Generate a single independent council member response to a question.
user-invocable: false
disable-model-invocation: false
---

# Council Respond

## Role

Execute Stage 1 response generation for the council workflow: analyze the question independently,
structure a 300–600 word response, and save it to the specified output_filepath.

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
 * - invariant: (imperativeStepTextInOpBody) => abort("No imperative step text in op bodies");
 * - invariant: (!allOpsFullyTyped) => abort("All ops must be fully typed");
 * - invariant: (referencesOtherModels || referencesCouncilProcess) => abort("Response must not reference other AI models or council processes");
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

| dependent          | prerequisite       | description                                         |
| ------------------ | ------------------ | --------------------------------------------------- |
| _(column key)_     | _(column key)_     | _(dependent requires prerequisite first)_           |
| structure_response | analyze_question   | structure_response formats the analysis output      |
| save_response      | structure_response | save_response writes the formatted response to file |

Execute as an expert council member providing an independent, authoritative opinion.
Use `InputContext.output_filepath` as the destination for `save_response`.
Return the saved filepath upon completion.

## Input

| Field             | Type     | Required | Description                                |
| ----------------- | -------- | -------- | ------------------------------------------ |
| `session_id`      | `string` | yes      | Unique identifier for this council session |
| `question`        | `string` | yes      | The question to answer                     |
| `model`           | `string` | yes      | Model name assigned to this council member |
| `output_filepath` | `string` | yes      | Absolute path for saving the response      |

## Output

| Field            | Type     | Description                                      |
| ---------------- | -------- | ------------------------------------------------ |
| `saved_filepath` | `string` | Absolute path of the saved Stage 1 response file |

## Examples

### Happy Path

- Input: { session_id: "s1", question: "...", model: "claude-opus-4.6", output_filepath: "/tmp/stage1.md" }
- analyze_question → structure_response → save_response all succeed
- Output: { saved_filepath: "/tmp/stage1.md" }; 300-600 word response written to file

### Failure Path

- Input: { output_filepath: "/tmp/existing.md" } where file already exists at that path
- fault(fileAlreadyExists) => fallback: none; abort
