#!/usr/bin/env bash
set -euo pipefail

if [ $# -gt 0 ]; then
  sh_files=()
  toml_files=()
  md_files=()
  py_files=()
  for file in "$@"; do
    case "$file" in
      *.sh) sh_files+=("$file") ;;
      *.toml) toml_files+=("$file") ;;
      *.md) md_files+=("$file") ;;
      *.py) py_files+=("$file") ;;
    esac
  done
else
  sh_files=()
  while IFS= read -r file; do sh_files+=("$file"); done < <(git ls-files '*.sh')
  toml_files=()
  while IFS= read -r file; do toml_files+=("$file"); done < <(git ls-files '*.toml')
  md_files=()
  while IFS= read -r file; do md_files+=("$file"); done < <(git ls-files '*.md')
  py_files=()
  while IFS= read -r file; do py_files+=("$file"); done < <(git ls-files '*.py')
fi

if [ ${#sh_files[@]} -gt 0 ]; then shfmt -w -i 2 -ci -- "${sh_files[@]}"; fi
if [ ${#toml_files[@]} -gt 0 ]; then taplo format "${toml_files[@]}"; fi
if [ ${#md_files[@]} -gt 0 ]; then prettier --write "${md_files[@]}"; fi
if [ ${#py_files[@]} -gt 0 ]; then uv run ruff format -- "${py_files[@]}"; fi
