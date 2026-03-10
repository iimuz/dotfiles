# Copilot Instructions

## Operational Constraints

### Core Philosophy

- ALWAYS prioritize current requirements over future extensibility (YAGNI).
- ALWAYS prioritize maintenance ease over theoretical correctness.
- ALWAYS favor simple, readable code over clever solutions (KISS: Keep It Simple, Stupid).
- ALWAYS plan before executing complex operations.
- ALWAYS match security level to project scope (personal/internal/public).

### Subagent Strategy and Parallel Execution

- ALWAYS use subagents to offload heavy-context operations and keep the main context focused.
- NEVER use subagents for micro-operations such as single-file reads, tiny edits, or one-step lookups.
- ALWAYS delegate cohesive workflows with crisp input context and explicit output contracts.
- ALWAYS execute independent subagent workflows in parallel rather than sequentially.
- ALWAYS launch multiple parallel subagents to test distinct hypotheses for complex or ambiguous tasks.

### Model Selection

- ALWAYS use claude-opus-4.6 as the default model; prioritize accuracy over speed.
- ALWAYS use gpt-5.3-codex for implementation tasks (code generation, file editing, commit preparation).
- ALWAYS use gemini-3-pro-preview for synthesis, summarization, and exploration tasks.

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
