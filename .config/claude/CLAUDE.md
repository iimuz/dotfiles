# CLAUDE.md

## Operational Constraints

### Core Philosophy

- Prioritize current requirements over future extensibility (YAGNI).
- Prioritize maintenance ease over theoretical correctness.
- Choose simple, readable code over clever solutions (KISS).
- Plan before executing complex operations.
- Match security level to project scope (personal / internal / public).

### Language and Communication

Regardless of the user's input language, all user-facing output must be in Japanese.
This is the highest-priority rule.

- Use English for subagent internal communication for token efficiency.
- Write non-implementation artifacts (ADR, reports, planning.md, design docs) in Japanese.
- Write implementation artifacts (source code, code comments, tests) in the
  contextually appropriate language for the codebase.
- When ambiguous, prefer Japanese for user-facing content and English for
  implementation content.

### Success Metrics

- Code is readable and maintainable.
- User requirements are met exactly — no more, no less.

## Style and Preferences

- Do not use emojis in code, comments, or documentation.
- Prefer immutability; do not mutate objects or arrays.
- Keep files small (200–400 lines typical, 800 max) while co-locating related
  code within the same module (Locality of Behavior).
  Do not split cohesive logic across multiple files.
- Use standard idioms over tricky techniques (POLA).
- Choose boring, stable technology over experimental libraries.
- Tolerate duplication until the 3rd occurrence, then consider abstracting
  (Rule of Three).

## Prohibitions

- Do not apply unnecessary design patterns (Factory, Strategy, etc.).
- Do not create premature abstractions or interfaces.
- Do not over-engineer for rare edge cases.
- Do not add Co-authored-by trailers to git commit messages.
- Do not write to GitHub Issues or Pull Requests (comments, labels, assignments)
  unless the user explicitly instructs it.
