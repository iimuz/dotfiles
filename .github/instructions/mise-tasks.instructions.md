---
applyTo: ".mise/tasks/**"
---

# Mise Tasks

## Naming Convention

- Rule: Always include a file extension (`.sh` for shell scripts).
- Reason: mise uses the filename without extension as the task name.
- Effect: Adding an extension does not affect task invocation (`mise run format`, `mise run lint`).
- Exclusion: Without an extension, the file is excluded from `git ls-files '*.sh'` globs.
- Example: `format.sh` becomes task `format`, `lint.sh` becomes task `lint`.
- Forbidden: Adding files without an extension.

## Script Conventions

- Shebang: Use `#!/usr/bin/env bash` as the shebang line.
- Safety: Use `set -euo pipefail` at the top.
- Verification: Run `mise run lint` and `mise run format` after changes.
