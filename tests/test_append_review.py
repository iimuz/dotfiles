"""Tests for append_review.py."""

import json
import sys
from types import SimpleNamespace

import pytest
from gh_ops import append_review

_COMMENTS = json.dumps([{"path": "a.py", "line": 1, "body": "x"}])


def _argv() -> list[str]:
    return [
        "append_review.py",
        "--owner",
        "o",
        "--repo",
        "r",
        "--pull-number",
        "1",
        "--comments-json",
        _COMMENTS,
    ]


def _patch_run(monkeypatch, responses):
    calls = []

    def fake_run(cmd, **kwargs):
        calls.append(cmd)
        return responses.pop(0)

    monkeypatch.setattr(append_review.subprocess, "run", fake_run)
    return calls


def _find_response(nodes):
    body = {"data": {"repository": {"pullRequest": {"reviews": {"nodes": nodes}}}}}
    return SimpleNamespace(returncode=0, stdout=json.dumps(body), stderr="")


def test_appends_to_existing_pending_review(monkeypatch, capsys):
    responses = [
        _find_response([{"id": "REV1", "viewerDidAuthor": True}]),
        SimpleNamespace(
            returncode=0,
            stdout=json.dumps({"data": {"addPullRequestReviewThread": {"thread": {"id": "TH1"}}}}),
            stderr="",
        ),
    ]
    calls = _patch_run(monkeypatch, responses)
    monkeypatch.setattr(sys, "argv", _argv())

    append_review.main()

    out = json.loads(capsys.readouterr().out)
    assert out["review_id"] == "REV1"
    assert out["added"] == 1
    assert out["thread_ids"] == ["TH1"]
    assert len(calls) == 2  # find query + one mutation


def test_errors_when_no_pending_review(monkeypatch, capsys):
    responses = [_find_response([])]
    calls = _patch_run(monkeypatch, responses)
    monkeypatch.setattr(sys, "argv", _argv())

    with pytest.raises(SystemExit) as exc:
        append_review.main()

    assert exc.value.code != 0
    err = json.loads(capsys.readouterr().err)
    assert err["error"] == "no_pending_review"
    assert len(calls) == 1  # only the find query, no mutation
