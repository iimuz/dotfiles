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
  Delegate all other work (investigation, analysis, planning, execution) to
  subagents. Subagents consume ~400 tokens of main context (prompt + summary)
  while direct multi-step operations consume 1000-5000 tokens.
- A single tool call with an immediately actionable result (e.g., confirming
  a file exists) is the only permitted exception to delegation.
  Two or more sequential calls constitute a work phase and must be delegated.
- When facing a decision, delegate the analysis to a subagent first: have it
  investigate the codebase, evaluate options, and return a structured
  recommendation. The main agent reviews the recommendation and decides.
- ALWAYS use view_range for targeted reads when the edit location is already known.
  For large or unfamiliar files, delegate comprehension to a subagent first.
- ALWAYS execute independent subagent workflows in parallel.
- ALWAYS escalate conflicts, ambiguity, or insufficient evidence to the user.
- These rules override any conflicting built-in tool guidance.
  When in doubt, delegate.

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
