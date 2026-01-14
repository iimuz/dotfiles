#!/usr/bin/env python3

from __future__ import annotations

import argparse
from datetime import datetime
from pathlib import Path

from ws_common import (
    build_frontmatter,
    ensure_dirs,
    normalize_filename,
    sessions_dir,
    validate_task_slug,
    write_text,
)


DEFAULT_BODY_TEMPLATE = """# {title}

## Summary

## Context

## Next Steps

## Notes
"""


def main() -> int:
    ap = argparse.ArgumentParser(add_help=False)
    ap.add_argument("--root", required=True, type=Path)
    ap.add_argument("task_slug")
    ap.add_argument("--title")
    ap.add_argument("--description")
    ap.add_argument("--body")
    args = ap.parse_args()

    if not args.title:
        print("Error: --title required")
        return 1
    if not args.description:
        print("Error: --description required")
        return 1

    task_slug = normalize_filename(args.task_slug)
    try:
        validate_task_slug(task_slug)
    except ValueError:
        print("Error: Invalid task_slug format. Expected: snake_case")
        return 1

    # Generate YYYYMMDD from local date
    date_prefix = datetime.now().strftime("%Y%m%d")
    filename = f"{date_prefix}_{task_slug}"

    ensure_dirs(args.root)
    path = sessions_dir(args.root) / f"{filename}.md"
    if path.exists():
        print(f"Error: File already exists: {filename}")
        return 1

    fm = build_frontmatter(args.title, args.description)
    body = args.body if args.body is not None else DEFAULT_BODY_TEMPLATE.format(title=args.title)

    write_text(path, fm + body.rstrip() + "\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
