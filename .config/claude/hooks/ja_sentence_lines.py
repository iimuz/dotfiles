#!/usr/bin/env python3
"""PostToolUse hook: break untracked Markdown at sentence ends with ja-sentence-lines."""

import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

_TOOL = "ja-sentence-lines"
_CONFIG_NAMES = (
    "lefthook",
    ".lefthook",
    ".config/lefthook",
    "lefthook-local",
    ".lefthook-local",
    ".config/lefthook-local",
)
_CONFIG_EXTENSIONS = (".yml", ".yaml", ".json", ".jsonc", ".toml")


def _opted_in(root: str) -> bool:
    # lefthook reads only the first file found per kind; any file naming the tool counts here.
    needle = _TOOL.encode()
    for name in _CONFIG_NAMES:
        for ext in _CONFIG_EXTENSIONS:
            try:
                if needle in (Path(root) / f"{name}{ext}").read_bytes():
                    return True
            except OSError:
                continue
    return False


def _git(cwd: str, *args: str) -> subprocess.CompletedProcess[str] | None:
    try:
        return subprocess.run(["git", *args], cwd=cwd, capture_output=True, text=True, check=False)
    except OSError:
        return None


def should_format(file_path: str) -> bool:
    """Return True for files git does not track, in a repo whose lefthook config names the tool."""
    # Resolve symlinks first: a link to a tracked file would otherwise look untracked.
    real = os.path.realpath(file_path)
    top = _git(os.path.dirname(real), "rev-parse", "--show-toplevel")
    if top is None or top.returncode != 0:
        return False
    root = top.stdout.strip()
    tracked = _git(root, "ls-files", "--error-unmatch", "--", real)
    if tracked is None or tracked.returncode == 0:
        return False
    return _opted_in(root)


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
