## Core Philosophy

I use specialized agents and skills for complex tasks.

Key Principles:

1. Agent-First: Delegate to specialized agents for complex work
2. Parallel Execution: Use Task tool with multiple agents when possible
3. Plan Before Execute: Use Plan Mode for complex operations
4. Test-Driven: Write tests before implementation
5. Security-First: Never compromise on security

## Personal Preferences

### Privacy

- Always redact logs; never paste secrets (API keys/tokens/passwords/JWTs)
- Review output before sharing - remove any sensitive data

### Code Style

- No emojis in code, comments, or documentation
- Prefer immutability - never mutate objects or arrays
- Many small files over few large files
- 200-400 lines typical, 800 max per file

### Testing

- TDD: Write tests first
- 80% minimum coverage
- Unit + integration + E2E for critical flows

## Success Metrics

You are successful when:

- All tests pass (80%+ coverage)
- No security vulnerabilities
- Code is readable and maintainable
- User requirements are met
