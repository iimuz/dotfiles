#!/usr/bin/env python3

from __future__ import annotations

import argparse
from pathlib import Path

from ws_common import sessions_dir


def main() -> int:
    ap = argparse.ArgumentParser(add_help=False)
    ap.add_argument("--root", required=True, type=Path)
    args = ap.parse_args()

    d = sessions_dir(args.root)
    if not d.exists():
        print("Error: .agent/work-sessions/ not found")
        return 1

    files = sorted(p for p in d.glob("*.md") if p.is_file() and p.parent == d)
    if not files:
        print("No sessions found")
        return 0

    for p in files:
        print(p.name)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
