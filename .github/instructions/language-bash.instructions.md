---
applyTo: "**/*.sh"
---

# Bash

## Architecture

- ALWAYS keep each function focused on one responsibility with a single observable effect.
- ALWAYS declare functions before first use in the same file.
- ALWAYS pass data into functions via arguments instead of relying on implicit global state.
- NEVER mutate global variables from helper functions unless the variable name is documented at file scope.
- NEVER source another script using a relative path without anchoring it to the current script directory.

## Error Handling

- ALWAYS validate required argument counts at the start of each public function.
- ALWAYS return non-zero from functions on failure and propagate that failure to callers.
- ALWAYS send diagnostic error messages to stderr.
- NEVER ignore command failures by appending `|| true` unless the failure is explicitly expected and handled.
- NEVER continue execution after a failed precondition check.

## Testing

- ALWAYS mock external commands in tests by overriding `PATH` with test doubles.
- ALWAYS run shell script tests in isolated temporary directories and clean up artifacts after each test.
- NEVER run shell script tests against real production resources, user home directories, or live network services.

## Security

- ALWAYS document intentional unquoted expansions inline when relying on controlled word splitting or glob expansion.
- ALWAYS use `--` to terminate option parsing before passing user-controlled values to external commands.
- ALWAYS create temporary files and directories with `mktemp`.
- ALWAYS pass secrets through environment variables or temporary files with mode 0600.
- ALWAYS clear or unset secret variables after use.
- NEVER execute user-controlled data as shell code.
- NEVER embed secrets in command arguments that are visible via process listings.
- NEVER log or echo secrets to stdout or stderr.
- NEVER use `eval` unless input is constant and defined within the same file.

## Naming Conventions

- ALWAYS use lowercase snake_case for function names.
- ALWAYS use uppercase snake_case for exported environment variables.
- ALWAYS use descriptive variable names that encode intent, not implementation detail.
- NEVER reuse the same variable name for unrelated meanings within the same function.
- NEVER use single-letter names outside loop iterators.

## Idioms

- ALWAYS split complex command substitutions into named intermediate variables to preserve readability and safe nesting.
- ALWAYS use `printf` for formatted or escaped output.
- ALWAYS iterate over arrays with `for item in "${array[@]}"; do` to preserve element boundaries.
- ALWAYS choose null-delimited file enumeration patterns when filenames may contain whitespace, newlines, or glob characters.
- NEVER use unbounded pipelines when a direct shell builtin can express the same check.

## Portability

- ALWAYS document required shell and tool assumptions at the top of the file.
- ALWAYS gate shell-specific features behind an explicit shell compatibility check.
- ALWAYS prefer POSIX-compliant constructs when bash-specific behavior is not required.
- NEVER rely on GNU-only command flags without a fallback for BSD or POSIX variants.
- NEVER hardcode platform-specific absolute paths when a standard environment variable can be used.
