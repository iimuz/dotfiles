---
name: task-coordinator-synthesize
description: Synthesize pipeline worker outputs into a unified result via Synthesizer subagent.
user-invocable: false
disable-model-invocation: true
---

# Task Coordinator: Synthesize

## Role

Synthesis phase of the task-coordinator pipeline. Spawns a Synthesizer subagent to
unify worker outputs into a single synthesis document (pipeline mode only).

## Interface

```typescript
/**
 * @skill task-coordinator-synthesize
 * @input  { plan: Plan; receipts: WorkerReceipt[] }
 * @output { receipt: SynthesisReceipt }
 */

// Mirrored from task-coordinator (canonical source)
type Plan = {
  schema_version: string;
  run_id: string;
  goal: string;
  tasks: Task[];
  synthesis_output_file: string;
};

type Task = {
  id: string;
  agent_type: AgentType;
  prompt_file: string;
  output_file: string;
  depends_on: string[];
  description?: string;
  model?: string;
};

type AgentType = "explore" | "task" | "general-purpose" | "code-review";
type WorkerReceipt = {
  status: "WORKER_OK" | "WORKER_FAIL";
  id: string;
  reason?: string;
};
type SynthesisReceipt = {
  status: "SYNTHESIS_OK" | "SYNTHESIS_FAIL";
  output_file: string;
  summary: string;
  /* 2-4 sentences */ reason?: string;
};
```

## Operations

```typespec
op synthesize(p: Plan, receipts: WorkerReceipt[]) -> SynthesisReceipt {
  // Pipeline mode only; set synthesizer_protocol_file = {skill_base_dir}/references/synthesizer-protocol.md
  // Spawn Synthesizer: task(prompt="Read {synthesizer_protocol_file} and follow instructions.\n\n## Input Context\n- goal: {p.goal}\n- output_files: {p.tasks[*].output_file}\n- synthesis_output_file: {p.synthesis_output_file}")

  invariant: (synthesizer_fails)       => retry_once("refined prompt");
  invariant: (synthesizer_fails_again) => report_paths("synthesis_output_file + output_files; do not load inline");
  invariant: (reads_synthesis_file and !explicit_user_request) => warn("synthesis.md: load only on explicit request");
}
```

## Execution

```text
synthesize
```

## References

Subagent-only: pass file path to the Synthesizer subagent; do not load into caller context.

- `synthesizer_protocol_file` = `{skill_base_dir}/references/synthesizer-protocol.md`
