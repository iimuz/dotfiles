#!/usr/bin/env python3

from __future__ import annotations

import argparse
from pathlib import Path

from ws_common import load_session, normalize_filename, sessions_dir, split_frontmatter


def main() -> int:
    ap = argparse.ArgumentParser(add_help=False)
    ap.add_argument("--root", required=True, type=Path)
    ap.add_argument("filename")
    ap.add_argument("--description", action="store_true")
    args = ap.parse_args()

    name = normalize_filename(args.filename)
    path = sessions_dir(args.root) / f"{name}.md"
    if not path.exists():
        print(f"Error: File not found: {name}")
        return 1

    if args.description:
        s = load_session(path)
        print(s.frontmatter.get("description", ""))
        return 0

    text = path.read_text(encoding="utf-8")
    _, body = split_frontmatter(text)
    print(body.lstrip("\n").rstrip() + "\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
