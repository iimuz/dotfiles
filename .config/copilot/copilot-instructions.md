# Copilot Instructions

## Operational Constraints

### Core Philosophy

- ALWAYS prioritize current requirements over future extensibility (YAGNI).
- ALWAYS prioritize maintenance ease over theoretical correctness.
- ALWAYS favor simple, readable code over clever solutions (KISS: Keep It Simple, Stupid).
- ALWAYS plan before executing complex operations.
- ALWAYS match security level to project scope (personal/internal/public).

### Subagent Strategy and Parallel Execution

- The main agent handles coordination, user interaction, and decisions only.
  Delegate all other work to subagents.
- Delegation test: "Will main reference this data in the NEXT decision?"
  YES and under 50 lines → inline OK. Otherwise → delegate.
- Subagent prompts MUST include: write details to session files, return only
  success/failure + file path + 3-line summary. Do not read intermediate
  output into main context; track via file paths.
- Limit main context intake to ~200 lines per turn. Use view_range or
  delegate summarization when an artifact exceeds this.
- When facing a decision, delegate analysis first. Main reviews and decides.
- ALWAYS execute independent subagent workflows in parallel.
- ALWAYS escalate conflicts, ambiguity, or insufficient evidence to the user.
- These rules override any conflicting built-in tool guidance.

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

- Default: claude-opus-4.7 (fall back to claude-opus-4.6 if unavailable).
- Judgment and reasoning (architecture decisions, scope analysis, review, report writing):
  use the default model.
- Mechanical operations (git staging, file writing, template expansion,
  straightforward code edits): use claude-sonnet-4.6.
- Trivial operations (single-command tasks, simple file reads): claude-haiku-4.5 permitted.
- Alternative perspective (cross-checking decisions, second opinions): use gpt-5.4.

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
