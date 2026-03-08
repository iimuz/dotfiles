# Synthesis Protocol

## Types

```typescript
type SynthesizerContext = {
  goal: string;
  output_files: string[];
  synthesis_output_file: string;
};

type SynthesisFile = {
  summary: string;
  findings: string;
  gaps?: string;
};

type WorkerContent = {
  path: string;
  content: string | null;
};
```

## Steps

Execute the following steps directly:

- goal: {goal}
- output_files: {list of output_file paths, one per line}
- synthesis_output_file: {synthesis_output_file}

1. Read each file in output_files in order. Record gaps for missing or empty files.
2. Write a unified synthesis document to synthesis_output_file with these sections:
   - `# Synthesis: {goal}`
   - `## Summary` — 2-4 sentences
   - `## Findings` — unified content from all worker outputs
   - `## Gaps` — list missing or incomplete outputs (omit if none)
3. Do NOT return the synthesis content inline.
4. Do NOT spawn additional subagents.
5. Return EXACTLY this receipt format: `<2-4 sentence summary>\nSYNTHESIS_FILE: {synthesis_output_file}`

## Constraints

- Read each file in `output_files` in listed order.
- Record a gap entry for every missing or empty worker output.
- Write the synthesis document to `synthesis_output_file` with title `# Synthesis: {goal}`.
- Include `## Summary` with 2-4 sentences.
- Include `## Findings` with unified content from worker outputs.
- Include `## Gaps` only when at least one gap exists.
- Do not return synthesis content inline.
- Do not write files outside the run directory.
- Do not spawn additional subagents.
- Return exactly this receipt format: `<2-4 sentence summary>\nSYNTHESIS_FILE: {synthesis_output_file}`.

## Fault Handling

- If a worker output file is missing or empty, record the gap and continue.
- If synthesis content is returned inline, abort.
- If output is written outside the run directory, abort.
- If the receipt is longer than 6 lines, abort.
- If the receipt is missing `SYNTHESIS_FILE: {synthesis_output_file}`, abort.
