#!/usr/bin/env bash

# Guard if cmux is not available.
if ! type cmux >/dev/null 2>&1; then return 0; fi

# Open a new cmux workspace at a directory selected via fzf.
# Usage: cxnw [workspace-name]
#   workspace-name: Optional name for the workspace. Defaults to the basename of the selected directory.
cxnw() {
  local -r selected_dir="$(find "${SOURCE_ROOT:-$HOME/src}" -follow -maxdepth "${FFGHQ_MAXDEPTH:-3}" -mindepth "${FFGHQ_MINDEPTH:-3}" -type d | fzf)"
  if [ -z "$selected_dir" ]; then
    return 0
  fi

  local -r ws_name="${1:-$(basename "$selected_dir")}"
  local -r result="$(cmux new-workspace --name "$ws_name" --cwd "$selected_dir")"
  local -r ws_ref="$(echo "$result" | awk '{print $2}')"
  if [ -n "$ws_ref" ]; then
    cmux select-workspace --workspace "$ws_ref"
  fi
}

# Open the current git repository on GitHub in a browser pane to the right.
# Usage: cxgho
cxgho() {
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "cxgho: not a git repository" >&2
    return 1
  fi

  local -r url="$(gh browse --no-browser 2>/dev/null)"
  if [ -z "$url" ]; then
    echo "cxgho: failed to get GitHub URL" >&2
    return 1
  fi

  cmux new-pane --type browser --direction right --url "$url"
}
