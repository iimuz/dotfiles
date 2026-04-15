# Copilot Instructions

## Operational Constraints

### Core Philosophy

- ALWAYS prioritize current requirements over future extensibility (YAGNI).
- ALWAYS prioritize maintenance ease over theoretical correctness.
- ALWAYS favor simple, readable code over clever solutions (KISS: Keep It Simple, Stupid).
- ALWAYS plan before executing complex operations.
- ALWAYS match security level to project scope (personal/internal/public).

### Subagent Strategy and Parallel Execution

- ALWAYS delegate to subagents by default to offload heavy-context operations and keep the main context focused.
- NEVER put raw source code or verbose output in the main context; keep it to decisions, coordination, and conclusions.
- ALWAYS delegate cohesive, goal-oriented workflows with crisp context, explicit output contracts, and evidence-backed conclusions.
- ALWAYS execute independent subagent workflows in parallel rather than sequentially.
- ALWAYS launch multiple parallel subagents to test distinct hypotheses for complex or ambiguous tasks.
- ALWAYS escalate conflicts, ambiguity, or insufficient evidence to the user for explicit resolution.

### Language and Communication

- ALWAYS respond to the user in Japanese regardless of the user's input language;
  this covers all user-facing output: responses, questions, explanations, and summaries.
- ALWAYS keep sub-agent internal communication in English for token efficiency.
- ALWAYS write non-implementation artifacts (ADR, reports, planning.md, design docs) in Japanese.
- ALWAYS write implementation artifacts (source code, code comments, tests) in the
  contextually appropriate language for the codebase.
- When the language choice is ambiguous, prefer Japanese for user-facing or
  non-implementation content, and English for internal or implementation content.

### Model Selection

- ALWAYS use claude-opus-4.6 as the default model; prioritize accuracy over speed.
- ALWAYS use claude-opus-4.6 for tasks requiring judgment, reasoning, or contextual understanding
  (architecture decisions, scope analysis, review interpretation, report writing).
- ALWAYS use gpt-5.4 for mechanical operations (git staging, file writing, template expansion,
  straightforward code edits with clear specifications).

### Privacy

- ALWAYS redact logs; NEVER paste secrets (API keys, tokens, passwords, JWTs).
- ALWAYS review output before sharing; remove any sensitive data.

### Success Metrics

- ALWAYS ensure code is readable and maintainable.
- ALWAYS ensure user requirements are met exactly (no more, no less).

### Task Completion Protocol

- ALWAYS call ask_user (allow_freeform: true) as the final action when completing a user request, regardless of task size.

## Style and Preferences

- NEVER use emojis in code, comments, or documentation.
- ALWAYS prefer immutability; NEVER mutate objects or arrays.
- ALWAYS prefer many small files (200-400 lines typical, 800 max) while keeping related code
  co-located within the same module (LoB: Locality of Behavior);
  NEVER split cohesive logic across multiple files.
- ALWAYS use standard idioms over clever techniques (POLA: Principle of Least Astonishment).
- ALWAYS choose boring, stable technology over experimental libraries.
- ALWAYS duplicate code until the 3rd occurrence before abstracting (Rule of Three / WET).

## Prohibitions

- NEVER use unnecessary design patterns (Factory, Strategy, etc.).
- NEVER create premature abstractions or interfaces.
- NEVER over-engineer for rare edge cases.
- NEVER add Co-authored-by trailers to git commit messages.
- NEVER write to GitHub Issues or Pull Requests (comments, labels, assignments) without explicit user instruction.

## Tools

### RTK — Token-Optimized CLI

**rtk** is a CLI proxy that filters and compresses command outputs, saving 60-90% tokens.

#### Rule

Always prefix shell commands with `rtk`:

```bash
# Instead of:              Use:
git status                 rtk git status
git log -10                rtk git log -10
cargo test                 rtk cargo test
docker ps                  rtk docker ps
kubectl get pods           rtk kubectl pods
```

#### Meta commands (use directly)

```bash
rtk proxy <cmd>       # Run raw (no filtering) but track usage
```
