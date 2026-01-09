#!/usr/bin/env python3

from __future__ import annotations

import re
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Dict, Tuple


RE_TASK_SLUG = re.compile(r"^[a-z0-9_]+$")
RE_HEADING = re.compile(r"^(#{1,6})\s+(.*)$")


def sessions_dir(root: Path) -> Path:
    """Return the .agent/work-sessions directory under the given root."""
    return root / ".agent" / "work-sessions"


def normalize_filename(name: str) -> str:
    """Remove .md extension if present."""
    name = name.strip()
    if name.endswith(".md"):
        name = name[: -len(".md")]
    return name


def validate_task_slug(slug: str) -> None:
    """Validate that task_slug is snake_case ASCII."""
    if not RE_TASK_SLUG.match(slug):
        raise ValueError("Invalid task_slug format. Expected: snake_case")


@dataclass
class ParsedSession:
    frontmatter: Dict[str, str]
    body: str


def split_frontmatter(text: str) -> Tuple[str, str]:
    """Return (frontmatter_raw, body)."""
    if not text.startswith("---\n"):
        raise ValueError("Missing YAML frontmatter")

    end = text.find("\n---\n", 4)
    if end == -1:
        raise ValueError("Invalid frontmatter format")

    fm = text[4:end]
    body = text[end + len("\n---\n") :]
    return fm, body


def parse_frontmatter(fm_raw: str) -> Dict[str, str]:
    """Parse YAML-like frontmatter into dict."""
    fm: Dict[str, str] = {}
    for line in fm_raw.splitlines():
        if not line.strip():
            continue
        m = re.match(r"^([A-Za-z0-9_-]+):\s*(.*)$", line)
        if not m:
            continue
        key = m.group(1)
        val = m.group(2).strip()
        if (val.startswith('"') and val.endswith('"')) or (val.startswith("'") and val.endswith("'")):
            val = val[1:-1]
        fm[key] = val
    return fm


def build_frontmatter(title: str, description: str) -> str:
    """Build frontmatter string with title and description only."""
    return "\n".join(
        [
            "---",
            f"title: {title}",
            f"description: {description}",
            "---",
            "",
        ]
    )


def ensure_dirs(root: Path) -> None:
    """Ensure .agent/work-sessions and archive/ directories exist."""
    d = sessions_dir(root)
    (d / "archive").mkdir(parents=True, exist_ok=True)


def load_session(path: Path) -> ParsedSession:
    """Load and parse a session file."""
    text = path.read_text(encoding="utf-8")
    fm_raw, body = split_frontmatter(text)
    fm = parse_frontmatter(fm_raw)
    return ParsedSession(frontmatter=fm, body=body)


def find_section(body: str, name: str) -> Tuple[int, int]:
    """
    Find section by exact heading match (case-insensitive).
    Return (start_line_idx, end_line_idx_exclusive).
    """
    lines = body.splitlines()

    name_lower = name.strip().lower()
    start = None
    start_level = None
    
    for i, line in enumerate(lines):
        m = RE_HEADING.match(line)
        if not m:
            continue
        title = m.group(2).strip().lower()
        if title == name_lower:
            start = i
            start_level = len(m.group(1))
            break

    if start is None or start_level is None:
        raise ValueError(f"Section not found: {name}")

    end = len(lines)
    for j in range(start + 1, len(lines)):
        m2 = RE_HEADING.match(lines[j])
        if not m2:
            continue
        level2 = len(m2.group(1))
        if level2 <= start_level:
            end = j
            break

    return start, end


def write_text(path: Path, text: str) -> None:
    """Write text to file."""
    path.write_text(text, encoding="utf-8")
