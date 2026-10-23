#!/usr/bin/env python3
"""PostToolUse hook: break untracked Markdown at sentence ends with ja-sentence-lines."""

import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

_TOOL = "ja-sentence-lines"


def _git(cwd: str, *args: str) -> subprocess.CompletedProcess[str] | None:
    try:
        return subprocess.run(["git", *args], cwd=cwd, capture_output=True, text=True, check=False)
    except OSError:
        return None


def should_format(file_path: str) -> bool:
    """Return True for files git does not track, in a repo that opted in via lefthook-local.yml."""
    # Resolve symlinks first: a link to a tracked file would otherwise look untracked.
    real = os.path.realpath(file_path)
    top = _git(os.path.dirname(real), "rev-parse", "--show-toplevel")
    if top is None or top.returncode != 0:
        return False
    root = top.stdout.strip()
    tracked = _git(root, "ls-files", "--error-unmatch", "--", real)
    if tracked is None or tracked.returncode == 0:
        return False
    try:
        return _TOOL in (Path(root) / "lefthook-local.yml").read_text(encoding="utf-8")
    except OSError:
        return False


def main() -> int:
    try:
        payload = json.load(sys.stdin)
    except json.JSONDecodeError:
        return 0
    file_path = (payload.get("tool_input") or {}).get("file_path")
    if not isinstance(file_path, str) or not file_path.endswith(".md"):
        return 0
    tool = shutil.which(_TOOL)
    if tool is None or not should_format(file_path):
        return 0

    real = os.path.realpath(file_path)
    try:
        before = Path(real).read_bytes()
    except OSError:
        return 0
    result = subprocess.run([tool, real], capture_output=True, text=True, check=False)
    if result.returncode != 0:
        sys.stderr.write(result.stderr)
        return 1
    if Path(real).read_bytes() == before:
        return 0

    message = (
        f"{file_path} was reformatted to one sentence per line by {_TOOL}. "
        "Read it again before editing it."
    )
    print(
        json.dumps(
            {"hookSpecificOutput": {"hookEventName": "PostToolUse", "additionalContext": message}}
        )
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
