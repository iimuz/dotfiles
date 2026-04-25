# Commit Type Reference

Valid types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `ci`, `build`, `perf`,
`style`, `revert`, `i18n`.

- `feat`: New features
- `fix`: Bug fixes
- `docs`: Documentation changes
- `refactor`: Code refactoring
- `test`: Test additions or corrections
- `chore`: Maintenance tasks, scripts, config
- `ci`: CI configuration and scripts
- `build`: Build system or external dependency changes
- `perf`: Performance improvements
- `style`: Code style changes (formatting, whitespace)
- `revert`: Revert previous commits
- `i18n`: Internationalization

## Selection Priority

When multiple types could apply, use this priority (highest first):

1. Whitespace or formatting only -> `style`
2. Only test files changed -> `test`
3. Only documentation files changed -> `docs`
4. Otherwise -> analyze the diff and pick the most specific type above.

Choose exactly one type. Reject any type not listed. Abort with `invalid commit type`
on mismatch.
