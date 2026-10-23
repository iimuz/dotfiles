#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.10"
# dependencies = ["markdown-it-py>=4,<5"]
# ///
"""Break paragraphs of Japanese Markdown at sentence ends, one sentence per line."""

# ruff: noqa: RUF001 (the fullwidth punctuation in the patterns below is the point of this tool)

import argparse
import re
import subprocess
import sys
from collections.abc import Callable
from functools import lru_cache
from pathlib import Path

from markdown_it import MarkdownIt

Selector = Callable[[int, int], bool]

_JA_CHAR = re.compile("[々぀-ヿ㐀-䶿一-鿿豈-﫿ｦ-ﾟ]")
_JA_JOIN_CHAR = re.compile("[　-〿぀-ヿ㐀-䶿一-鿿豈-﫿＀-￯]")
_HIRAGANA = re.compile("[ぁ-ゟ]")
_CALLOUT = re.compile(r"^\[![^\]]+\]")
_FOOTNOTE_DEF = re.compile(r"^\[\^[^\]]+\]:")
_LIST_MARKER = re.compile(r"[-*+]|\d{1,9}[.)]")
_HUNK = re.compile(r"^@@ -\d+(?:,\d+)? \+(\d+)(?:,(\d+))? @@", re.MULTILINE)

# Spans whose inside must not be split, joined, or counted for brackets.
_PROTECTED = re.compile(
    r"(?<!`)(`+)(?!`).*?(?<!`)\1(?!`)"
    r"|!?\[\[[^\]]*\]\]"
    r"|!?\[[^\]]*\]\([^)]*\)"
    r"|\[[^\]]*\]\[[^\]]*\]"
    r"|<[^>\n]+>"
    r"|\$[^$]+\$",
    re.DOTALL,
)

_SENTENCE_END = "。！？"
_OPEN = "「『（【〔〈《［｛“‘("
_CLOSE = "」』）】〕〉》］｝”’)"
_TRAILING_MARKS = "*_~"


@lru_cache(maxsize=1)
def _parser() -> MarkdownIt:
    return MarkdownIt("commonmark").enable("table")


def _protected_spans(text: str) -> list[tuple[int, int]]:
    return [m.span() for m in _PROTECTED.finditer(text)]


def _join_lines(content: str) -> str:
    spans = _protected_spans(content)
    pieces: list[str] = []
    start = 0
    for m in re.finditer("\n", content):
        if any(s <= m.start() < e for s, e in spans):
            continue
        pieces.append(content[start : m.start()])
        start = m.end()
    pieces.append(content[start:])

    joined = pieces[0]
    for piece in pieces[1:]:
        left = joined.rstrip(" \t")
        right = piece.lstrip(" \t")
        if (
            not left
            or not right
            or (_JA_JOIN_CHAR.match(left[-1]) and _JA_JOIN_CHAR.match(right[0]))
        ):
            joined = left + right
        else:
            joined = f"{left} {right}"
    return joined


def _split_sentences(text: str) -> list[str]:
    spans = dict(_protected_spans(text))
    sentences: list[str] = []
    start = 0
    depth = 0
    i = 0
    while i < len(text):
        if i in spans:
            i = spans[i]
            continue
        ch = text[i]
        if ch in _OPEN:
            depth += 1
        elif ch in _CLOSE:
            depth = max(0, depth - 1)
        elif ch in _SENTENCE_END:
            j = i + 1
            closed = False
            while j < len(text) and text[j] in _SENTENCE_END + _CLOSE + _TRAILING_MARKS:
                if text[j] in _CLOSE:
                    closed = True
                    depth = max(0, depth - 1)
                j += 1
            rest = text[j:].lstrip()
            # A closing bracket followed by hiragana means the sentence continues.
            if not rest or depth > 0 or (closed and _HIRAGANA.match(rest[0])):
                i = j
                continue
            sentences.append(text[start:j])
            start = len(text) - len(rest)
            i = start
            continue
        i += 1
    sentences.append(text[start:])
    return sentences


def _line_prefixes(lines: list[str], content_lines: list[str]) -> list[str] | None:
    prefixes = []
    for line, content_line in zip(lines, content_lines, strict=True):
        stripped = line.rstrip()
        body = content_line.rstrip()
        if not body or not stripped.endswith(body):
            return None
        prefixes.append(stripped[: len(stripped) - len(body)])
    return prefixes


def _frontmatter_end(lines: list[str]) -> int:
    if not lines or lines[0].rstrip() != "---":
        return 0
    for i in range(1, len(lines)):
        if lines[i].rstrip() in ("---", "..."):
            return i + 1
    return 0


def _block_lines(lines: list[str]) -> set[int]:
    """Return line indexes inside `$$` or `%%` blocks, which Markdown parsers do not know."""
    protected: set[int] = set()
    marker = None
    for i, line in enumerate(lines):
        token = line.strip()
        if marker is None:
            if token in ("$$", "%%"):
                marker = token
                protected.add(i)
        else:
            protected.add(i)
            if token == marker:
                marker = None
    return protected


def _kept_types(content: str) -> list[str] | None:
    """Return inline child types without text/softbreak, or None if not a single paragraph."""
    tokens = _parser().parse(content)
    if [t.type for t in tokens] != ["paragraph_open", "inline", "paragraph_close"]:
        return None
    return [c.type for c in tokens[1].children or [] if c.type not in ("text", "softbreak")]


def _new_content_lines(content_lines: list[str]) -> list[str] | None:
    before = "\n".join(content_lines)
    after = _split_sentences(_join_lines(before))
    new_content = "\n".join(s for s in after if s)
    kept_before = _kept_types(before)
    if kept_before is None or _kept_types(new_content) != kept_before:
        return None
    return new_content.split("\n")


def _rewrite_paragraph(lines: list[str], content: str) -> list[str] | None:
    content_lines = content.split("\n")
    if len(content_lines) != len(lines):
        return None
    prefixes = _line_prefixes(lines, content_lines)
    if prefixes is None:
        return None

    skip = 1 if _CALLOUT.match(content_lines[0]) else 0
    if skip and len(lines) == 1:
        return None
    target = content_lines[skip:]
    if not _JA_CHAR.search("\n".join(target)):
        return None

    new_lines = _new_content_lines(target)
    if new_lines is None:
        return None

    first_prefix = prefixes[skip]
    if len(target) > 1:
        rest_prefix = prefixes[skip + 1]
    else:
        rest_prefix = _LIST_MARKER.sub(lambda m: " " * len(m.group()), first_prefix, count=1)
    result = [(first_prefix if i == 0 else rest_prefix) + line for i, line in enumerate(new_lines)]
    return [*lines[:skip], *result]


def format_markdown(text: str, select: Selector | None = None) -> str:
    if "\r\n" in text:
        return text
    lines = text.split("\n")
    parse_lines = list(lines)
    for i in range(_frontmatter_end(lines)):
        parse_lines[i] = ""
    blocked = _block_lines(lines)

    replacements: dict[int, tuple[int, list[str]]] = {}
    tokens = _parser().parse("\n".join(parse_lines))
    for idx, token in enumerate(tokens):
        if token.type != "paragraph_open" or token.map is None:
            continue
        start, end = token.map
        inline = tokens[idx + 1]
        if any(start <= n < end for n in blocked):
            continue
        if select is not None and not select(start, end):
            continue
        if any(c.type == "hardbreak" for c in inline.children or []):
            continue
        content = inline.content
        if "$$" in content or "%%" in content or _FOOTNOTE_DEF.match(content):
            continue
        new_lines = _rewrite_paragraph(lines[start:end], content)
        if new_lines is not None and new_lines != lines[start:end]:
            replacements[start] = (end, new_lines)

    out: list[str] = []
    i = 0
    while i < len(lines):
        if i in replacements:
            end, new_lines = replacements[i]
            out.extend(new_lines)
            i = end
        else:
            out.append(lines[i])
            i += 1
    return "\n".join(out)


def changed_selector(diff: str) -> Selector:
    changed: set[int] = set()
    boundaries: set[tuple[int, int]] = set()
    for m in _HUNK.finditer(diff):
        c = int(m.group(1))
        n = int(m.group(2)) if m.group(2) is not None else 1
        if n >= 1:
            changed.update(range(c - 1, c - 1 + n))
        else:
            boundaries.add((c - 1, c))

    def select(start: int, end: int) -> bool:
        if any(start <= line < end for line in changed):
            return True
        return any(start <= a and b < end for a, b in boundaries)

    return select


def _staged_diff(path: str) -> str:
    result = subprocess.run(
        ["git", "diff", "--cached", "--no-color", "--no-ext-diff", "-U0", "--", path],
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode != 0:
        raise RuntimeError(result.stderr.strip() or "git diff failed")
    return result.stdout


def _format_file(path: str, changed_only: bool) -> None:
    file = Path(path)
    original = file.read_bytes().decode("utf-8")
    select = changed_selector(_staged_diff(path)) if changed_only else None
    formatted = format_markdown(original, select)
    if formatted != original:
        file.write_bytes(formatted.encode("utf-8"))


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--changed",
        action="store_true",
        help="only format paragraphs changed in the git index",
    )
    parser.add_argument("files", nargs="*")
    args = parser.parse_args(argv)

    if not args.files:
        sys.stdout.write(format_markdown(sys.stdin.read()))
        return 0

    status = 0
    for path in args.files:
        try:
            _format_file(path, args.changed)
        except (OSError, RuntimeError, UnicodeDecodeError) as e:
            print(f"{path}: {e}", file=sys.stderr)
            status = 1
    return status


if __name__ == "__main__":
    sys.exit(main())
