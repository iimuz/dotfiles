import io
import json
import os
import subprocess
import sys

import pytest
from config.claude.hooks.ja_sentence_lines import main, should_format


@pytest.fixture(autouse=True)
def _clean_git_env(monkeypatch):
    # A pre-commit hook run exports GIT_* variables that would redirect these git calls
    for name in [n for n in os.environ if n.startswith("GIT_")]:
        monkeypatch.delenv(name)


_ENABLING_CONFIG = "pre-commit:\n  jobs:\n    - run: ja-sentence-lines --changed {staged_files}\n"


def _git(cwd, *args):
    subprocess.run(["git", *args], cwd=cwd, check=True, capture_output=True)


def make_enabled_repo(path):
    path.mkdir(parents=True)
    _git(path, "init", "-q")
    _git(path, "config", "user.name", "t")
    _git(path, "config", "user.email", "t@example.com")
    _git(path, "config", "commit.gpgsign", "false")
    (path / "tracked.md").write_text("追跡。\n")
    _git(path, "add", "tracked.md")
    _git(path, "commit", "-q", "-m", "init")
    (path / ".gitignore").write_text("docs/\n")
    _git(path, "add", ".gitignore")
    _git(path, "commit", "-q", "-m", "ignore")
    (path / "notes.md").write_text("未追跡。\n")
    (path / "docs").mkdir()
    (path / "docs" / "plan.md").write_text("無視。\n")
    (path / "lefthook-local.yml").write_text(_ENABLING_CONFIG)
    return path


@pytest.fixture
def enabled_repo(tmp_path):
    return make_enabled_repo(tmp_path / "repo")


@pytest.fixture
def plain_repo(enabled_repo):
    (enabled_repo / "lefthook-local.yml").unlink()
    return enabled_repo


def _install_tool(tmp_path, monkeypatch, body):
    bin_dir = tmp_path / "bin"
    bin_dir.mkdir()
    script = bin_dir / "ja-sentence-lines"
    script.write_text(f"#!/bin/sh\n{body}\n")
    script.chmod(0o755)
    monkeypatch.setenv("PATH", f"{bin_dir}{os.pathsep}{os.environ['PATH']}")


@pytest.fixture
def fake_tool(tmp_path, monkeypatch):
    _install_tool(tmp_path, monkeypatch, 'echo extra >> "$1"')


@pytest.fixture
def noop_tool(tmp_path, monkeypatch):
    _install_tool(tmp_path, monkeypatch, "exit 0")


def _send(monkeypatch, file_path):
    payload = json.dumps({"tool_input": {"file_path": str(file_path)}})
    monkeypatch.setattr(sys, "stdin", io.StringIO(payload))


def test_untracked_file_in_enabled_repo(enabled_repo):
    assert should_format(str(enabled_repo / "notes.md"))


def test_ignored_file_in_enabled_repo(enabled_repo):
    assert should_format(str(enabled_repo / "docs" / "plan.md"))


def test_tracked_file_is_skipped(enabled_repo):
    assert not should_format(str(enabled_repo / "tracked.md"))


def test_repo_without_config_is_skipped(plain_repo):
    assert not should_format(str(plain_repo / "notes.md"))


@pytest.mark.parametrize(
    "name",
    [
        "lefthook.yml",
        ".lefthook.yaml",
        ".config/lefthook.toml",
        "lefthook-local.json",
        ".config/lefthook-local.jsonc",
    ],
)
def test_config_file_with_tool_enables_hook(plain_repo, name):
    config = plain_repo / name
    config.parent.mkdir(parents=True, exist_ok=True)
    config.write_text(_ENABLING_CONFIG)
    assert should_format(str(plain_repo / "notes.md"))


def test_main_config_without_tool_is_skipped(plain_repo):
    (plain_repo / "lefthook.yml").write_text("pre-commit:\n  jobs: []\n")
    assert not should_format(str(plain_repo / "notes.md"))


def test_local_config_enables_when_main_config_lacks_tool(enabled_repo):
    (enabled_repo / "lefthook.yml").write_text("pre-commit:\n  jobs: []\n")
    assert should_format(str(enabled_repo / "notes.md"))


def test_non_utf8_config_with_tool_enables_hook(plain_repo):
    (plain_repo / "lefthook-local.yml").write_bytes(b"# \xff\n" + _ENABLING_CONFIG.encode())
    assert should_format(str(plain_repo / "notes.md"))


def test_directory_with_config_name_is_passed_over(plain_repo):
    (plain_repo / "lefthook.yml").mkdir()
    (plain_repo / ".lefthook.yml").write_text(_ENABLING_CONFIG)
    assert should_format(str(plain_repo / "notes.md"))


def test_local_config_without_tool_is_skipped(plain_repo):
    (plain_repo / "lefthook-local.yml").write_text("pre-commit:\n  jobs: []\n")
    assert not should_format(str(plain_repo / "notes.md"))


def test_symlink_to_tracked_file_is_skipped(enabled_repo, tmp_path):
    other = make_enabled_repo(tmp_path / "other")
    link = other / "link.md"
    link.symlink_to(enabled_repo / "tracked.md")
    assert not should_format(str(link))


def test_file_outside_git_is_skipped(tmp_path):
    path = tmp_path / "loose" / "a.md"
    path.parent.mkdir()
    path.write_text("本文。\n")
    assert not should_format(str(path))


def test_main_reports_rewrite(enabled_repo, fake_tool, monkeypatch, capsys):
    path = enabled_repo / "notes.md"
    _send(monkeypatch, path)
    assert main() == 0
    out = json.loads(capsys.readouterr().out)
    assert out["hookSpecificOutput"]["hookEventName"] == "PostToolUse"
    assert str(path) in out["hookSpecificOutput"]["additionalContext"]


def test_main_silent_when_unchanged(enabled_repo, noop_tool, monkeypatch, capsys):
    _send(monkeypatch, enabled_repo / "notes.md")
    assert main() == 0
    assert capsys.readouterr().out == ""


def test_main_ignores_non_markdown(enabled_repo, fake_tool, monkeypatch, capsys):
    path = enabled_repo / "notes.txt"
    path.write_text("本文。\n")
    _send(monkeypatch, path)
    assert main() == 0
    assert capsys.readouterr().out == ""
    assert path.read_text() == "本文。\n"


def test_main_without_tool_on_path(enabled_repo, tmp_path, monkeypatch, capsys):
    empty = tmp_path / "empty"
    empty.mkdir()
    monkeypatch.setenv("PATH", str(empty))
    _send(monkeypatch, enabled_repo / "notes.md")
    assert main() == 0
    assert capsys.readouterr().out == ""
