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
    ap.add_argument("--new-section", required=True)
    ap.add_argument("--level", type=int, required=True)
    ap.add_argument("--content", required=True)
    ap.add_argument("--before")
    ap.add_argument("--after")
    args = ap.parse_args()

    if args.before and args.after:
        print("Error: Cannot specify both --before and --after")
        return 1

    if args.level < 1 or args.level > 6:
        print("Error: Level must be 1-6")
        return 1

    name = normalize_filename(args.filename)
    path = sessions_dir(args.root) / f"{name}.md"
    if not path.exists():
        print(f"Error: File not found: {name}")
        return 1

    text = path.read_text(encoding="utf-8")
    _, body = split_frontmatter(text)
    parsed = load_session(path)

    lines = body.splitlines()
    hdr = "#" * args.level + " " + args.new_section
    insert_block = [hdr, "", args.content.rstrip(), ""]

    if args.before or args.after:
        base_name = args.before if args.before else args.after
        try:
            start, end = find_section(body, base_name)
        except ValueError as e:
            print(f"Error: {e}")
            return 1

        if args.before:
            idx = start
        else:
            idx = end

        body2 = "\n".join(lines[:idx] + insert_block + lines[idx:]).lstrip("\n")
    else:
        # Append to end
        body2 = "\n".join(lines + [""] + insert_block).lstrip("\n")

    fm = build_frontmatter(
        parsed.frontmatter.get("title", ""),
        parsed.frontmatter.get("description", "")
    )
    write_text(path, fm + body2.rstrip() + "\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
