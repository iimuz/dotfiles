#!/usr/bin/env python3

from __future__ import annotations

import argparse
from pathlib import Path

from ws_common import (
    build_frontmatter,
    find_section,
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
    ap.add_argument("--section")
    args = ap.parse_args()

    name = normalize_filename(args.filename)
    path = sessions_dir(args.root) / f"{name}.md"
    if not path.exists():
        print(f"Error: File not found: {name}")
        return 1

    if args.section:
        # Delete section
        text = path.read_text(encoding="utf-8")
        _, body = split_frontmatter(text)
        parsed = load_session(path)

        try:
            start, end = find_section(body, args.section)
        except ValueError as e:
            print(f"Error: {e}")
            return 1

        lines = body.splitlines()
        body2 = "\n".join(lines[:start] + lines[end:]).lstrip("\n")

        fm = build_frontmatter(
            parsed.frontmatter.get("title", ""),
            parsed.frontmatter.get("description", "")
        )
        write_text(path, fm + body2.rstrip() + "\n")
        return 0
    else:
        # Delete file
        path.unlink()
        return 0


if __name__ == "__main__":
    raise SystemExit(main())
