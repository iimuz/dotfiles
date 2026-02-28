# Core Philosophy

## Pragmatic Priorities

- Current requirements over future extensibility (YAGNI: You Aren't Gonna Need It)
- Maintenance ease over theoretical correctness
- Simple, readable code over clever solutions (KISS: Keep It Simple, Stupid)

## Principles

- Agent-First: Delegate to specialized agents for complex work
- Parallel Execution: Use Task tool with multiple agents when possible
- Plan Before Execute: Use Plan Mode for complex operations
- Test-Driven: Write tests before implementation
- Context-Aware Security: Match security level to project scope (personal/internal/public)

## Personal Preferences

### Privacy

- Always redact logs; never paste secrets (API keys/tokens/passwords/JWTs)
- Review output before sharing - remove any sensitive data

### Code Style

- No emojis in code, comments, or documentation
- Prefer immutability - never mutate objects or arrays
- Many small files over few large files
- 200-400 lines typical, 800 max per file
- Standard idioms over clever techniques (POLA: Principle of Least Astonishment)
- Boring/stable technology over experimental libraries
- Keep related code close (LoB: Locality of Behavior) - avoid excessive file splitting
- Duplicate code until 3rd occurrence before abstracting (WET: Write Everything Twice / Rule of Three)

### Testing

- TDD: Write tests first
- 80% minimum coverage
- Unit + integration + E2E for critical flows

## Prohibited

- Unnecessary design patterns (Factory, Strategy, etc.)
- Premature abstraction or interface creation
- Splitting cohesive logic across multiple files
- Over-engineering for rare edge cases
- Adding Co-authored-by trailers to git commit messages
- Writing to GitHub Issues or Pull Requests (comments, labels, assignments, etc.) without explicit user instruction

## Success Metrics

- All tests pass (80%+ coverage)
- Code is readable and maintainable
- User requirements are met (no more, no less)
