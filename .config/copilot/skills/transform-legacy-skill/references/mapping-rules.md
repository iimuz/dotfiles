# Mapping Rules: Legacy Markdown → Spec-First Hybrid

Detailed transformation rules with annotated before/after examples for each legacy section type.

---

## 1. `description` → Goal-Only Description

Strip implementation details. Retain only the goal statement.

**Before (Legacy)**
```yaml
description: >
  This skill orchestrates a 3-stage multi-LLM deliberation workflow:
  1. Read references/prompt.md.
  2. Inject {user_question}.
  3. Call claude-opus to synthesize.
  Use for complex questions.
```

**After (Spec-First)**
```yaml
description: >
  Produce high-quality answers by synthesizing perspectives from multiple LLMs.
  Use for complex questions benefiting from collective deliberation.
```

**Rule**: Remove numbered steps, file-read instructions, and injection language. Keep purpose + trigger.

---

## 2. `## Workflow` Steps → `op` Declarations

Remove imperative language ("Read", "Inject", "Call"). Express as typed input-output mappings.

**Before (Legacy)**
```markdown
### Stage 1
1. Read references/stage1-prompt.md.
2. Inject {user_question} with the actual question.
3. Launch 3 parallel task() calls with model="claude-opus".
4. Collect responses. If fewer than 2 succeed, abort.
```

**After (Spec-First)**
```typespec
op generate_stage1(question: string) -> Response[] {
  task(model: "claude-opus-4.6", prompt: @references/stage1-prompt.md);
  invariant: (responses.length < 2) => abort("Quorum not met");
}
```

**Rules**:
- Step sequence → single `op` with pipeline-expressed logic
- `Read X` → `@references/X` reference in op body
- `Inject {var}` → function parameter `var: Type`
- `If condition, action` → `invariant: (condition) => action`
- Numbered steps disappear; I/O contract is the contract

---

## 3. `## Council Configuration` / `## Model Configuration` → `ModelRole` Type

Upgrade legacy model names using `MappingRegistry`. Retain unknown model names unchanged.

**Before (Legacy)**
```markdown
| Role    | Model       | Purpose              |
|---------|-------------|----------------------|
| Writer  | claude-opus | Deep reasoning       |
| Critic  | gpt-4       | Structured analysis  |
| Checker | gemini-pro  | Broad knowledge      |
```

**After (Spec-First)**
```typescript
type ModelRoles = {
  Writer:  "claude-opus-4.6";   // upgraded from claude-opus
  Critic:  "gpt-5.3-codex";     // upgraded from gpt-4
  Checker: "gemini-3-pro-preview"; // upgraded from gemini-pro
};
```

**MappingRegistry**
```typescript
type MappingRegistry = {
  "claude-opus": "claude-opus-4.6";
  "gpt-4":       "gpt-5.3-codex";
  "gemini-pro":  "gemini-3-pro-preview";
};
```

**Fallback Policy**: Model names not present in `MappingRegistry` are retained verbatim.
```typescript
// Example: "mistral-7b" not in registry → retained as "mistral-7b"
type CustomRoles = {
  Local: "mistral-7b"; // no mapping available; retained as-is
};
```

---

## 4. `## Error Handling` → `invariant` Expressions

Convert table rows to logical `Condition => Action` expressions embedded in the relevant `op`.

**Before (Legacy)**
```markdown
| Condition                          | Behavior                    |
|------------------------------------|-----------------------------|
| Fewer than 2 responses             | Abort with quorum error     |
| Exactly 2 responses                | Continue in degraded mode   |
| Stage 2 prep failure               | Launch fallback synthesis   |
```

**After (Spec-First)**
```typespec
op generate_responses(question: string) -> Response[] {
  invariant: (count < 2) => abort("Quorum not met: fewer than 2 responses");
  invariant: (count == 2) => warn("Degraded mode: only 2/3 responses");
}

op prepare_stage2(responses: Response[]) -> PrepResult {
  invariant: (prep_failed) => fallback(synthesize_fallback(responses));
}
```

**Rules**:
- Each table row → one `invariant:` line in the relevant op
- `Abort` → `abort("message")`
- `Continue in degraded mode` → `warn("message")`
- `Launch fallback X` → `fallback(X)`
- `Retry` → `retry_with(alternative_args)`
- Assign invariants to the op that owns the condition, not a global block

---

## 5. Long Prompt References → `@references/filename.md`

Externalize inline prompt content longer than **10 lines**.

**Before (Legacy)**
```markdown
### Stage 1
1. Read references/stage1-prompt.md.
2. Inject {user_question}.
```

**After (Spec-First)**
```typespec
op run_stage1(question: string) -> Response {
  task(prompt: @references/stage1-prompt.md, vars: { user_question: question });
}
```

**Before (Legacy — inline prompt exceeding 10 lines)**
```markdown
Use the following instructions:
You are a synthesizer. Your goal is to...
[12 more lines of instructions]
```

**After (Spec-First)**
```typespec
op synthesize(inputs: string[]) -> string {
  task(prompt: @references/synthesizer-prompt.md, vars: { inputs });
  // Prompt content externalized: >10 lines
}
```

The externalized file stub `references/synthesizer-prompt.md` retains the original content verbatim.

**Threshold**: Content ≤ 10 lines may remain inline as a comment or short string literal.

---

## 6. General Transformation Checklist

After completing all section mappings, verify:

- [ ] No numbered imperative steps remain in `op` bodies
- [ ] Every `op` has explicit input parameter types and return type
- [ ] All legacy model names are resolved against `MappingRegistry`
- [ ] Unknown model names are retained verbatim (fallback policy applied)
- [ ] Error table rows are expressed as `invariant:` lines
- [ ] Inline prompts >10 lines are externalized to `@references/*.md`
- [ ] Stub reference files exist for every `@references/` citation
- [ ] `@invariants` block at Interface level captures cross-op invariants
