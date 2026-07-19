#!/usr/bin/env bash
set -euo pipefail

uv run pytest "$@"
bats tests/
