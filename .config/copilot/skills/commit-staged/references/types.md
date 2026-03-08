# Commit Type Reference

Complete list of valid commit types for Conventional Commits.

## Type Descriptions

| Type     | Description                                 | Examples                      |
| -------- | ------------------------------------------- | ----------------------------- |
| feat     | New features                                | add user authentication       |
| fix      | Bug fixes                                   | resolve token expiration      |
| docs     | Documentation changes                       | update API documentation      |
| refactor | Code refactoring                            | extract validation logic      |
| test     | Test additions or corrections               | add integration tests         |
| chore    | Maintenance tasks, scripts, config          | update dependencies           |
| ci       | CI configuration and scripts                | add GitHub Actions workflow   |
| build    | Build system or external dependency changes | upgrade webpack to v5         |
| perf     | Performance improvements                    | optimize database queries     |
| style    | Code style changes (formatting, whitespace) | apply code formatter          |
| revert   | Revert previous commits                     | revert authentication changes |
| i18n     | Internationalization                        | add Japanese translations     |

## Commit Type Selection Rules

Use the staged diff to choose the most specific type from the Type Descriptions table.

| Priority | Condition                                                | Required Type                                                               |
| -------- | -------------------------------------------------------- | --------------------------------------------------------------------------- |
| 1        | The change set is only whitespace or formatting updates. | `style`                                                                     |
| 2        | The change set touches only test files.                  | `test`                                                                      |
| 3        | The change set touches only documentation files.         | `docs`                                                                      |
| 4        | None of the above conditions apply.                      | Analyze the diff and select the most specific matching type from the table. |

## Constraints

- Match the diff against the table and choose exactly one type.
- Apply the priority rules in order so that higher-priority conditions always win.
- Reject any type that is not listed in the Type Descriptions table.

## Fault Handling

- If the selected type is not in the table, abort with `invalid commit type`.
