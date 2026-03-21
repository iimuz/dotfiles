---
applyTo: "**/*.sh"
---

# Bash

## Architecture

- Keep each function focused on one responsibility with a single observable effect.
- Declare functions before first use in the same file.
- Pass data into functions via arguments instead of relying on implicit global state.
- Do not mutate global variables from helper functions unless the variable name is documented at file scope.
- Do not source another script using a relative path without anchoring it to the current script directory.

## Error Handling

- Validate required argument counts at the start of each public function.
- Return non-zero from functions on failure and propagate that failure to callers.
- Send diagnostic error messages to stderr.
- Do not ignore command failures by appending `|| true` unless the failure is explicitly expected and handled.
- Do not continue execution after a failed precondition check.

## Security

- Document intentional unquoted expansions inline when relying on controlled word splitting or glob expansion.
- Use `--` to terminate option parsing before passing user-controlled values to external commands.
- Create temporary files and directories with `mktemp`.
- Pass secrets through environment variables or temporary files with mode 0600. Clear or unset secret variables after use.
- Do not execute user-controlled data as shell code.
- Do not embed secrets in command arguments that are visible via process listings.
- Do not log or echo secrets to stdout or stderr.
- Do not use `eval` unless input is constant and defined within the same file.

## Naming Conventions

- Use lowercase snake_case for function names.
- Use uppercase snake_case for exported environment variables.
- Use descriptive variable names that encode intent, not implementation detail.
- Do not reuse the same variable name for unrelated meanings within the same function.
- Do not use single-letter names outside loop iterators.

## Idioms

- Split complex command substitutions into named intermediate variables to preserve readability and safe nesting.
- Use `printf` for formatted or escaped output.
- Iterate over arrays with `for item in "${array[@]}"; do` to preserve element boundaries.
- Use null-delimited file enumeration patterns when filenames may contain whitespace, newlines, or glob characters.
- Do not use unbounded pipelines when a direct shell builtin can express the same check.

## Portability

- Document required shell and tool assumptions at the top of the file.
- Gate shell-specific features behind an explicit shell compatibility check.
- Prefer POSIX-compliant constructs when bash-specific behavior is not required.
- Do not rely on GNU-only command flags without a fallback for BSD or POSIX variants.
- Do not hardcode platform-specific absolute paths when a standard environment variable can be used.

## Testing

- Mock external commands in tests by overriding `PATH` with test doubles.
- Run shell script tests in isolated temporary directories and clean up artifacts after each test.
- Do not run shell script tests against real production resources, user home directories, or live network services.
