---
name: subagent-first
description: >
  Behavioral modifier that enforces delegation-first orchestration through task() subagents.
  This skill should be used when it is co-loaded with other skills that already define
  subagent/task() usage patterns and the main agent should act as intermediary only.
---

# Subagent-First

## Interface

```typescript
/**
 * @skill subagent-first
 * @input  { userIntent: string }
 * @output { result: SubagentResult }
 */

type RequestClass = "investigation" | "execution" | "trivial" | "user-explicit";

type SkillRef = {
  name: string;
  // true when skill's @input accepts a raw intent string directly (e.g. @input { question: string })
  acceptsRawIntent: boolean;
};

type SubagentResult = {
  status: "success" | "partial" | "failed";
  delegatedTo?: string;
  summary: string;
  error?: string;
};

/**
 * @invariants
 * 1. OrchestratorOnly:               main agent must not use bash/grep/glob/view for investigation while this skill is active
 * 2. DelegationMandated:             if a compatible co-loaded skill defines task()-based delegation and class is investigation/execution, delegation is required
 * 3. IntentPassthrough:              if target skill subagent accepts raw intent input, pass user intent verbatim with no pre-processing
 * 4. EscapeHatch:                    trivial requests (single factual question, no file operations needed) bypass delegation
 * 5. ExplicitOverride:               if user explicitly says "do it yourself" or equivalent, bypass delegation
 * 6. RecursionPrevention:            subagents launched by this skill must not re-apply subagent-first
 * 7. FailOpenOnUnknownCompatibility: if co-loaded skill compatibility cannot be confidently established, do not block normal handling
 */
```

## Operations

```typespec
op classify(userIntent: string) -> RequestClass {
  // Determine request class from intent content
  invariant: (intent_ambiguous) => default_to("investigation");
  invariant: (single_factual_question && no_file_ops) => return("trivial");
  invariant: (user_says_do_it_yourself) => return("user-explicit");
}

op delegate(intent: string, requestClass: RequestClass, targetSkill: SkillRef) -> SubagentResult {
  // Dispatch to appropriate subagent via task()
  invariant: (no_compatible_skill_found) => fail_open("handle normally without delegation");
}

op relay(result: SubagentResult) -> void {
  // Present delegated result to user
  invariant: (result.status == "failed" || result.status == "partial") => include(result.error);
}
```

## Execution

```text
classify -> [delegate -> relay] | direct
```

Skip `delegate` and `relay` when `classify` returns `trivial` or `user-explicit`.

When `delegate` is invoked, select the subagent type based on request class:

| Request Pattern                                      | Recommended task() agent_type |
| ---------------------------------------------------- | ----------------------------- |
| Codebase discovery, symbol search, file exploration  | `explore`                     |
| Build, test, lint, command execution                 | `task`                        |
| Multi-step implementation, code editing, refactoring | `general-purpose`             |
| Review-only analysis without code modification       | `code-review`                 |
