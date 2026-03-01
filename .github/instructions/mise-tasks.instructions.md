---
applyTo: ".mise/tasks/**"
---

# Mise Tasks

## Naming Convention

- Rule: Always include a file extension (`.sh` for shell scripts).
- Reason: mise uses the filename without extension as the task name.
- Example: `format.sh` becomes task `format`, `lint.sh` becomes task `lint`.

## Script Conventions

- Shebang: Use `#!/usr/bin/env bash` as the shebang line.
- Safety: Use `set -euo pipefail` at the top.
