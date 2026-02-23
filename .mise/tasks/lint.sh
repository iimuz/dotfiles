#!/usr/bin/env bash
set -euo pipefail

if [ $# -gt 0 ]; then
  sh_files=()
  md_files=()
  for file in "$@"; do
    case "$file" in
      *.sh) sh_files+=("$file") ;;
      *.md) md_files+=("$file") ;;
    esac
  done
else
  sh_files=()
  while IFS= read -r file; do sh_files+=("$file"); done < <(git ls-files '*.sh')
  md_files=()
  while IFS= read -r file; do md_files+=("$file"); done < <(git ls-files '*.md')
fi

if [ ${#sh_files[@]} -gt 0 ]; then shellcheck --severity=error -- "${sh_files[@]}"; fi
if [ ${#md_files[@]} -gt 0 ]; then markdownlint-cli2 "${md_files[@]}"; fi
