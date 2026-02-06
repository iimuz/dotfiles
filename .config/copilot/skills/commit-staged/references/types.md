# Commit Type Reference

Complete list of valid commit types for Conventional Commits.

## Type Descriptions

| Type     | Description                                 | Examples                           |
| -------- | ------------------------------------------- | ---------------------------------- |
| feat     | New features                                | add user authentication            |
| fix      | Bug fixes                                   | resolve token expiration           |
| docs     | Documentation changes                       | update API documentation           |
| refactor | Code refactoring                            | extract validation logic           |
| test     | Test additions or corrections               | add integration tests              |
| chore    | Maintenance tasks, scripts, config          | update dependencies                |
| ci       | CI configuration and scripts                | add GitHub Actions workflow        |
| build    | Build system or external dependency changes | upgrade webpack to v5              |
| perf     | Performance improvements                    | optimize database queries          |
| style    | Code style changes (formatting, whitespace) | apply code formatter               |
| revert   | Revert previous commits                     | revert authentication changes      |
| i18n     | Internationalization                        | add Japanese translations          |

## Selection Guidelines

- **feat**: User-facing new functionality
- **fix**: Corrects broken behavior
- **docs**: Only documentation changes (no code)
- **refactor**: Code structure improvements without behavior change
- **test**: Only test changes
- **chore**: Routine tasks, dependency updates, config tweaks
- **ci**: Only affects CI/CD pipeline
- **build**: Build tool or external dependency changes
- **perf**: Makes code faster or more efficient
- **style**: Whitespace, formatting, semicolons only
- **revert**: Undoes previous commit
- **i18n**: Translation or localization work
