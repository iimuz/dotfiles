# ruff: noqa: RUF001 (the fullwidth punctuation in the cases is the input under test)
import io
import os
import subprocess
import sys

import pytest
from config.ja_sentence_lines import changed_selector, format_markdown, main

CASES = {
    "basic": (
        "一文目です。\n二文目は\n途中で折れている。三文目。\n",
        "一文目です。\n二文目は途中で折れている。\n三文目。\n",
    ),
    "mixed_join": ("日本語と\nEnglish の\n混在。\n", "日本語と English の混在。\n"),
    "ja_join": ("日本語の\n文。\n", "日本語の文。\n"),
    "ascii_after_end": ("終わり。Next は英語。\n", "終わり。\nNext は英語。\n"),
    "space_after_end": ("終わり。 次の文。\n", "終わり。\n次の文。\n"),
    "quote_continues": (
        "彼は「行こう。」と言った。次の文。\n",
        "彼は「行こう。」と言った。\n次の文。\n",
    ),
    "quote_then_new": ("「行こう。」次の文。\n", "「行こう。」\n次の文。\n"),
    "inside_parens": ("例（A。B。）を示す。次。\n", "例（A。B。）を示す。\n次。\n"),
    "inside_halfwidth_parens": (
        "例 (注。詳しくは後で) を示す。次。\n",
        "例 (注。詳しくは後で) を示す。\n次。\n",
    ),
    "halfwidth_close_continues": ("補足 (注。) を示す。次。\n", "補足 (注。) を示す。\n次。\n"),
    "halfwidth_close_then_new": ("補足 (注。) 次の文。\n", "補足 (注。)\n次の文。\n"),
    "stray_close_paren": ("顔文字 :) を使う。次。\n", "顔文字 :) を使う。\n次。\n"),
    "repeated_marks": ("本当？！そうだ。\n", "本当？！\nそうだ。\n"),
    # CommonMark does not close "**" between "。" and a CJK letter, so the source keeps a space
    "emphasis": ("**重要。** 次の文。\n", "**重要。**\n次の文。\n"),
    "inline_code": ("`a。b` を使う。次。\n", "`a。b` を使う。\n次。\n"),
    "code_span_newline": ("`a\nb` の\n説明。\n", "`a\nb` の説明。\n"),
    "link": (
        "[リンク。先](https://x/。y) を見る。次。\n",
        "[リンク。先](https://x/。y) を見る。\n次。\n",
    ),
    "wikilink": ("[[ノート。名]] を参照。次。\n", "[[ノート。名]] を参照。\n次。\n"),
    "list_item": ("- 項目の\n  本文。続き。\n", "- 項目の本文。\n  続き。\n"),
    "ordered_single_line": ("1. 一つ目。二つ目。\n", "1. 一つ目。\n   二つ目。\n"),
    "blockquote": ("> 引用の\n> 本文。次。\n", "> 引用の本文。\n> 次。\n"),
    "lazy_blockquote": ("> 引用。次。\n続き。\n", "> 引用。\n> 次。\n> 続き。\n"),
    "lazy_list_item": ("- 文1。文2。\n続き。\n", "- 文1。\n  文2。\n  続き。\n"),
    "nested_list_item": ("- - 文1。文2。\n", "- - 文1。\n    文2。\n"),
    "callout": (
        "> [!NOTE]\n> 注意の\n> 本文。次。\n",
        "> [!NOTE]\n> 注意の本文。\n> 次。\n",
    ),
}

UNCHANGED = {
    "english_only": "First line\ncontinues. Second.\n",
    "fence": "```\n日本語。\n続き\n```\n",
    "table": "| 列。 | b |\n|---|---|\n| 値。続き | 2 |\n",
    "heading": "# 見出し。です\n",
    "hard_break_spaces": "一行目  \n二行目。\n",
    "hard_break_backslash": "一行目\\\n二行目。\n",
    "frontmatter": "---\ntitle: 日本語。\ndesc: 続き\n---\n\n本文。\n",
    "math_block": "$$\nx = 1。\ny\n$$\n",
    "comment_block": "%%\nメモ。\n続き\n%%\n",
    "html_block": "<div>\n日本語。\n続き\n</div>\n",
    "footnote_def": "[^1]: 脚注の定義。次の文。\n",
    "crlf": "一文目。\r\n二文目\r\n続き。\r\n",
    "already_formatted": "一文目。\n二文目。\n",
}


@pytest.mark.parametrize(("src", "expected"), CASES.values(), ids=CASES.keys())
def test_formats(src, expected):
    assert format_markdown(src) == expected


@pytest.mark.parametrize("src", UNCHANGED.values(), ids=UNCHANGED.keys())
def test_leaves_unchanged(src):
    assert format_markdown(src) == src


def test_keeps_paragraph_when_split_changes_structure():
    src = "例です。- 記号で始まる。\n"
    assert format_markdown(src) == src


def test_idempotent():
    src = "\n".join(s for s, _ in CASES.values())
    once = format_markdown(src)
    assert format_markdown(once) == once


def test_select_limits_paragraphs():
    src = "一つ目の\n段落。\n\n二つ目の\n段落。\n"
    assert format_markdown(src, select=lambda start, end: start == 0) == (
        "一つ目の段落。\n\n二つ目の\n段落。\n"
    )


def test_selector_added_lines():
    select = changed_selector("@@ -3,2 +3,3 @@\n")
    assert not select(0, 2)
    assert select(2, 5)
    assert not select(5, 7)


def test_selector_deletion_inside_paragraph():
    assert changed_selector("@@ -5,1 +4,0 @@\n")(2, 6)


def test_selector_deletion_at_boundary():
    select = changed_selector("@@ -5,1 +4,0 @@\n")
    assert not select(0, 4)
    assert not select(4, 6)


def _git(*args):
    subprocess.run(["git", *args], check=True, capture_output=True)


@pytest.fixture
def git_repo(tmp_path, monkeypatch):
    # A pre-commit hook run exports GIT_* variables that would redirect these git calls
    for name in [n for n in os.environ if n.startswith("GIT_")]:
        monkeypatch.delenv(name)
    monkeypatch.chdir(tmp_path)
    _git("init", "-q")
    _git("config", "user.name", "t")
    _git("config", "user.email", "t@example.com")
    _git("config", "commit.gpgsign", "false")
    return tmp_path


def test_changed_mode_keeps_untouched_paragraph(git_repo):
    (git_repo / "a.md").write_text("一つ目の\n段落。\n\n二つ目の\n段落。\n")
    _git("add", "a.md")
    _git("commit", "-q", "-m", "init")
    (git_repo / "a.md").write_text("一つ目の\n段落。\n\n二つ目の\n段落です。\n")
    _git("add", "a.md")
    assert main(["--changed", "a.md"]) == 0
    assert (git_repo / "a.md").read_text() == "一つ目の\n段落。\n\n二つ目の段落です。\n"


def test_changed_mode_new_file_formats_whole_file(git_repo):
    (git_repo / "b.md").write_text("新しい\n段落。\n")
    _git("add", "b.md")
    assert main(["--changed", "b.md"]) == 0
    assert (git_repo / "b.md").read_text() == "新しい段落。\n"


def test_file_mode_formats_whole_file(tmp_path):
    path = tmp_path / "c.md"
    path.write_text("一つ目の\n段落。\n")
    assert main([str(path)]) == 0
    assert path.read_text() == "一つ目の段落。\n"


def test_file_mode_does_not_rewrite_unchanged_file(tmp_path):
    path = tmp_path / "d.md"
    path.write_text("揃っている。\n")
    os.utime(path, ns=(1, 1))
    assert main([str(path)]) == 0
    assert path.stat().st_mtime_ns == 1


def test_stdin_mode(monkeypatch, capsys):
    monkeypatch.setattr(sys, "stdin", io.StringIO("本文の\n途中。\n"))
    assert main([]) == 0
    assert capsys.readouterr().out == "本文の途中。\n"


def test_missing_file_returns_error(tmp_path, capsys):
    assert main([str(tmp_path / "none.md")]) == 1
    assert "none.md" in capsys.readouterr().err
