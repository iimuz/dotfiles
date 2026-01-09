#!/usr/bin/env python3

from __future__ import annotations

import argparse
from pathlib import Path

from ws_common import (
    build_frontmatter,
    load_session,
    normalize_filename,
    sessions_dir,
    split_frontmatter,
    write_text,
)


def main() -> int:
    ap = argparse.ArgumentParser(add_help=False)
    ap.add_argument("--root", required=True, type=Path)
    ap.add_argument("filename")
    ap.add_argument("--title")
    ap.add_argument("--description")
    args = ap.parse_args()

    name = normalize_filename(args.filename)
    path = sessions_dir(args.root) / f"{name}.md"
    if not path.exists():
        print(f"Error: File not found: {name}")
        return 1

    text = path.read_text(encoding="utf-8")
    _, body = split_frontmatter(text)
    parsed = load_session(path)

    title = args.title if args.title is not None else parsed.frontmatter.get("title", "")
    description = args.description if args.description is not None else parsed.frontmatter.get("description", "")

    fm = build_frontmatter(title, description)
    write_text(path, fm + body.lstrip("\n").rstrip() + "\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
