#!/usr/bin/env python3

from __future__ import annotations

import re
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, Tuple


def sessions_dir(root: Path) -> Path:
    """Return the .agent/work-sessions directory under the given root."""
    return root / ".agent" / "work-sessions"


def normalize_filename(name: str) -> str:
    """Remove .md extension if present."""
    name = name.strip()
    if name.endswith(".md"):
        name = name[: -len(".md")]
    return name


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


def load_session(path: Path) -> ParsedSession:
    """Load and parse a session file."""
    text = path.read_text(encoding="utf-8")
    fm_raw, body = split_frontmatter(text)
    fm = parse_frontmatter(fm_raw)
    return ParsedSession(frontmatter=fm, body=body)
