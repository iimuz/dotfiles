# CORE_BELIEFS

## PROJECT_IDENTITY

- Name: [Project Name]
- Type: [e.g., Web App / CLI]
- Language: [e.g., TypeScript]

## TECH_STACK (Constraints)

- Runtime: [e.g., Node.js v20+]
- Framework: [e.g., Next.js 14]
- Database: [e.g., PostgreSQL]
- Testing: [e.g., Vitest]

## ROUTING

- Context & Constraints: `docs/core-beliefs.md`
- Design Documents: `docs/design/`
- Active Tasks: `docs/plans/active/`
- Tech Debt & State: `docs/debt/`
- Document Templates: `docs/templates/`

## ARCHITECTURE_PRINCIPLES

- Pattern: [e.g., Clean Architecture]
- Data_Flow: Unidirectional
- Error_Handling: Return Result types, no exceptions.

## CODING_STYLE (Non-Linter Rules)

- Comments: Explain 'Why', not 'What'.
- Naming: Verb-Noun for functions.
- State: Keep local unless shared.

## ANTI_PATTERNS (Forbidden)

- No 'any' type.
- No global variables.
- No hardcoded secrets.
