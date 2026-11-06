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


def _patch_run(monkeypatch, responses):
    calls = []

    def fake_run(cmd, **kwargs):
        calls.append(cmd)
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


def test_rejects_non_string_comment_body(monkeypatch, capsys):
    responses = [SimpleNamespace(returncode=0, stdout="[]", stderr="")]
    calls = _patch_run(monkeypatch, responses)
    argv = _argv()
    argv[-1] = json.dumps([{"path": "a.py", "line": 1, "body": None, "suggestion": "y"}])
    monkeypatch.setattr(sys, "argv", argv)

    with pytest.raises(SystemExit):
        create_review.main()

    assert json.loads(capsys.readouterr().err)["error"] == "invalid_comment"
    assert all("POST" not in cmd for cmd in calls)


def _submit_calls(monkeypatch, extra_argv):
    posted = []
    responses = [
        SimpleNamespace(returncode=0, stdout="[]", stderr=""),
        SimpleNamespace(returncode=0, stdout=json.dumps({"id": 7, "html_url": "u"}), stderr=""),
    ]

    def fake_run(cmd, **kwargs):
        posted.append(kwargs.get("input"))
        return responses.pop(0)

    monkeypatch.setattr(create_review.subprocess, "run", fake_run)
    monkeypatch.setattr(sys, "argv", _argv() + extra_argv)
    return posted


def test_submits_review_with_event(monkeypatch, capsys):
    posted = _submit_calls(monkeypatch, ["--event", "APPROVE"])

    create_review.main()

    assert json.loads(posted[1])["event"] == "APPROVE"
    assert json.loads(capsys.readouterr().out) == {"id": 7, "html_url": "u"}


def test_omits_event_without_flag(monkeypatch):
    posted = _submit_calls(monkeypatch, [])

    create_review.main()

    assert "event" not in json.loads(posted[1])


def test_rejects_unknown_event(monkeypatch):
    posted = _submit_calls(monkeypatch, ["--event", "MERGE"])

    with pytest.raises(SystemExit) as exc:
        create_review.main()

    assert exc.value.code != 0
    assert posted == []


def test_human_checked_signs_summary_and_every_comment(monkeypatch):
    comments = json.dumps(
        [
            {"path": "a.py", "line": 1, "body": "x", "suggestion": "y"},
            {"path": "b.py", "line": 2, "body": "z\n"},
        ]
    )
    posted = _submit_calls(
        monkeypatch, ["--event", "COMMENT", "--comments-json", comments, "--human-checked"]
    )

    create_review.main()

    sig = create_review.HUMAN_CHECKED_SIGNATURE
    assert sig == "<sub>👤 Checked by a human · drafted by Claude Code</sub>"
    payload = json.loads(posted[1])
    assert payload["body"] == f"s\n\n{sig}"
    assert payload["comments"][0]["body"] == f"x\n\n```suggestion\ny\n```\n\n{sig}"
    assert payload["comments"][1]["body"] == f"z\n\n{sig}"


def test_omits_signature_without_human_checked(monkeypatch):
    posted = _submit_calls(monkeypatch, ["--event", "COMMENT"])

    create_review.main()

    payload = json.loads(posted[1])
    assert payload["body"] == "s"
    assert payload["comments"][0]["body"] == "x"


def test_human_checked_leaves_empty_summary_unsigned(monkeypatch):
    posted = _submit_calls(monkeypatch, ["--summary-body", "", "--human-checked"])

    create_review.main()

    payload = json.loads(posted[1])
    assert payload["body"] == ""
    assert payload["comments"][0]["body"] == f"x\n\n{create_review.HUMAN_CHECKED_SIGNATURE}"
