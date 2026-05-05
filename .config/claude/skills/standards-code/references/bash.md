# Bash

- Template: [references/bash-template.sh](references/bash-template.sh)
- Pass data into functions via arguments. Do not rely on implicit global state.
- Validate required argument counts at the start of each public function.
- Send diagnostic messages to stderr. Return non-zero on failure.
- Use `mktemp` for temporary files. Pass secrets via environment variables or files with mode 0600.
- Do not use `eval` unless input is constant and defined within the same file.
- Use `printf` for formatted output. Use `"${array[@]}"` for safe iteration.
- Document required shell and tool assumptions at the top of the file.
- Mock external commands in tests by overriding `PATH` with test doubles.
