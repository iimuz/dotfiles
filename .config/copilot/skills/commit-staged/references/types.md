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

## Operations

```typespec
op select_type(diff: StagedDiff) -> CommitType {
  // Match diff to the most specific type using Type Descriptions table above
  invariant: (only_whitespace_or_formatting) => force("style");
  invariant: (only_test_files_changed)       => force("test");
  invariant: (only_doc_files_changed)        => force("docs");
  invariant: (type_not_in_table)             => abort("invalid commit type");
}
```
