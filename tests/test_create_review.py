"""Tests for create_review.py pending-review detection."""

import json
import sys
from types import SimpleNamespace

import pytest
from gh_ops import create_review

_COMMENTS = json.dumps([{"path": "a.py", "line": 1, "body": "x"}])


def _argv() -> list[str]:
    return [
        "create_review.py",
        "--owner",
        "o",
        "--repo",
        "r",
        "--pull-number",
        "1",
        "--summary-body",
        "s",
        "--comments-json",
        _COMMENTS,
    ]


def _patch_run(monkeypatch, responses, formatter=lambda t: t, formatter_returncode=0):
    calls = []

    def fake_run(cmd, **kwargs):
        if cmd[0] == "ja-sentence-lines":
            return SimpleNamespace(
                returncode=formatter_returncode, stdout=formatter(kwargs["input"]), stderr=""
            )
        calls.append((cmd, kwargs))
        return responses.pop(0)

    monkeypatch.setattr(create_review.subprocess, "run", fake_run)
    return calls


def test_aborts_when_pending_review_exists(monkeypatch, capsys):
    responses = [
        SimpleNamespace(returncode=0, stdout=json.dumps([{"id": 5, "state": "PENDING"}]), stderr="")
    ]
    calls = _patch_run(monkeypatch, responses)
    monkeypatch.setattr(sys, "argv", _argv())

    with pytest.raises(SystemExit) as exc:
        create_review.main()

    assert exc.value.code != 0
    err = json.loads(capsys.readouterr().err)
    assert err["error"] == "pending_review_exists"
    assert err["review_id"] == 5
    assert len(calls) == 1  # only the list-reviews call, no POST


def test_creates_when_no_pending_review(monkeypatch, capsys):
    responses = [
        SimpleNamespace(returncode=0, stdout="[]", stderr=""),
        SimpleNamespace(
            returncode=0, stdout=json.dumps({"id": 10, "html_url": "http://x"}), stderr=""
        ),
    ]
    calls = _patch_run(monkeypatch, responses)
    monkeypatch.setattr(sys, "argv", _argv())

    create_review.main()

    out = json.loads(capsys.readouterr().out)
    assert out["id"] == 10
    assert len(calls) == 2  # list-reviews then POST


def _post_payload(calls):
    cmd, kwargs = calls[-1]
    assert "POST" in cmd
    return json.loads(kwargs["input"])


def _ok_responses():
    return [
        SimpleNamespace(returncode=0, stdout="[]", stderr=""),
        SimpleNamespace(
            returncode=0, stdout=json.dumps({"id": 10, "html_url": "http://x"}), stderr=""
        ),
    ]


def test_formats_summary_and_comment_bodies(monkeypatch):
    calls = _patch_run(monkeypatch, _ok_responses(), formatter=lambda t: "[F]" + t)
    monkeypatch.setattr(sys, "argv", _argv())

    create_review.main()

    payload = _post_payload(calls)
    assert payload["body"] == "[F]s"
    assert payload["comments"][0]["body"] == "[F]x"


def test_suggestion_is_appended_after_formatting(monkeypatch):
    calls = _patch_run(monkeypatch, _ok_responses(), formatter=lambda t: "[F]" + t)
    argv = _argv()
    argv[-1] = json.dumps([{"path": "a.py", "line": 1, "body": "x", "suggestion": "y"}])
    monkeypatch.setattr(sys, "argv", argv)

    create_review.main()

    assert _post_payload(calls)["comments"][0]["body"] == "[F]x\n\n```suggestion\ny\n```"


def test_stops_when_formatter_fails(monkeypatch, capsys):
    calls = _patch_run(monkeypatch, _ok_responses(), formatter_returncode=1)
    monkeypatch.setattr(sys, "argv", _argv())

    with pytest.raises(SystemExit):
        create_review.main()

    assert json.loads(capsys.readouterr().err)["error"] == "format_body_failed"
    assert calls == []
