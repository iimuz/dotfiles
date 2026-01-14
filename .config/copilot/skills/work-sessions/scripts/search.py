#!/usr/bin/env python3

from __future__ import annotations

import argparse
import shutil
import subprocess
from pathlib import Path

from ws_common import sessions_dir


def main() -> int:
    ap = argparse.ArgumentParser(add_help=False)
    ap.add_argument("--root", required=True, type=Path)
    ap.add_argument("keyword", nargs="?")
    args = ap.parse_args()

    if not args.keyword:
        print("Error: Keyword required")
        return 1

    keyword = args.keyword
    d = sessions_dir(args.root)
    if not d.exists():
        print("Error: .agent/work-sessions/ not found")
        return 1

    rg = shutil.which("rg")
    if rg:
        cmd = [
            rg,
            "--line-number",
            "--no-heading",
            "--glob",
            "*.md",
            "--glob",
            "!archive/**",
            keyword,
            str(d),
        ]
        p = subprocess.run(cmd, text=True, capture_output=True)
        out = (p.stdout or "").rstrip()
        if out:
            prefix = str(d).rstrip("/") + "/"
            lines = []
            for line in out.splitlines():
                if line.startswith(prefix):
                    line = line[len(prefix) :]
                # Skip archive lines
                if line.startswith("archive/"):
                    continue
                # rg format: file:line:match
                parts = line.split(":", 2)
                if len(parts) == 3:
                    line = f"{parts[0]}:{parts[1]}: {parts[2]}"
                lines.append(line)
            if lines:
                print("\n".join(lines))
                return 0
        print("No results found")
        return 0

    # Fallback: minimal Python search
    results = []
    for path in d.glob("*.md"):
        if not path.is_file() or path.parent != d:
            continue
        for idx, line in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
            if keyword in line:
                results.append(f"{path.name}:{idx}: {line}")

    if results:
        print("\n".join(results))
        return 0

    print("No results found")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
