"""Tests for reply_review.py."""

import io
import json
import sys
from types import SimpleNamespace

import pytest
from gh_ops import reply_review

_SIG = "<sub>👤 Checked by a human · drafted by Claude Code</sub>"


def _run(monkeypatch, tmp_path, body, extra=(), response=None):
    path = tmp_path / "body.md"
    path.write_text(body, encoding="utf-8")
    calls = []

    def fake_run(cmd, **kwargs):
        calls.append((cmd, kwargs.get("input")))
        return response or SimpleNamespace(
            returncode=0, stdout=json.dumps({"id": 9, "html_url": "u"}), stderr=""
        )

    monkeypatch.setattr(reply_review.subprocess, "run", fake_run)
    argv = [
        "reply_review.py",
        "--owner",
        "o",
        "--repo",
        "r",
        "--pull-number",
        "1",
        "--comment-id",
        "11",
        "--body-file",
        str(path),
        *extra,
    ]
    monkeypatch.setattr(sys, "argv", argv)
    return calls


def test_posts_reply_to_the_comment(monkeypatch, tmp_path, capsys):
    calls = _run(monkeypatch, tmp_path, "x\n")

    reply_review.main()

    cmd, payload = calls[0]
    assert "repos/o/r/pulls/1/comments/11/replies" in cmd
    assert json.loads(payload) == {"body": "x\n"}
    assert json.loads(capsys.readouterr().out) == {"id": 9, "html_url": "u"}


def test_human_checked_appends_the_signature(monkeypatch, tmp_path):
    calls = _run(monkeypatch, tmp_path, "x\n", ["--human-checked"])

    reply_review.main()

    assert reply_review.HUMAN_CHECKED_SIGNATURE == _SIG
    assert json.loads(calls[0][1]) == {"body": f"x\n\n{_SIG}"}


def test_reads_the_body_from_stdin(monkeypatch, tmp_path):
    calls = _run(monkeypatch, tmp_path, "unused")
    sys.argv[sys.argv.index("--body-file") + 1] = "-"
    monkeypatch.setattr(sys, "stdin", io.StringIO("y"))

    reply_review.main()

    assert json.loads(calls[0][1]) == {"body": "y"}


def test_rejects_an_empty_body(monkeypatch, tmp_path, capsys):
    calls = _run(monkeypatch, tmp_path, " \n")

    with pytest.raises(SystemExit) as exc:
        reply_review.main()

    assert exc.value.code != 0
    assert json.loads(capsys.readouterr().err)["error"] == "empty_body"
    assert calls == []


def test_reports_a_gh_failure(monkeypatch, tmp_path, capsys):
    failed = SimpleNamespace(returncode=1, stdout="", stderr="HTTP 422: Unprocessable")
    _run(monkeypatch, tmp_path, "x", response=failed)

    with pytest.raises(SystemExit) as exc:
        reply_review.main()

    assert exc.value.code == 1
    err = json.loads(capsys.readouterr().err)
    assert err["error"] == "gh_api_failed"
    assert err["http_status"] == 422
