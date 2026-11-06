#!/usr/bin/env python3
import argparse
import json
import re
import subprocess
import sys
from typing import Any, NoReturn

__all__ = ["main"]

# Marks a reply that the user checked in the conversation before it was posted
# under the bot identity. gh-pr-review matches the whole line, so do not reword it.
# The emoji is a deliberate exception to the no-emoji rule: it makes the mark stand
# out in the PR UI.
HUMAN_CHECKED_SIGNATURE = "<sub>👤 Checked by a human · drafted by Claude Code</sub>"


def extract_http_status(stderr_text: str) -> int | None:
    match = re.search(r"HTTP\s+(\d{3})", stderr_text)
    if match is None:
        return None
    return int(match.group(1))


def sign(body: str) -> str:
    return f"{body.rstrip()}\n\n{HUMAN_CHECKED_SIGNATURE}"


def emit_error(message: str, *, exit_code: int = 1, **details: Any) -> NoReturn:
    error_payload = {"error": message, **details}
    print(json.dumps(error_payload), file=sys.stderr)
    sys.exit(exit_code)


def read_body(body_file: str) -> str:
    if body_file == "-":
        return sys.stdin.read()
    try:
        with open(body_file, encoding="utf-8") as f:
            return f.read()
    except OSError as error:
        emit_error("body_file_unreadable", detail=str(error))


def main() -> None:
    """
    Replies to a PR review thread. The comment id must be the first comment of
    the thread: GitHub rejects replies to replies.
    """
    parser = argparse.ArgumentParser(description="Reply to a PR review thread.")
    parser.add_argument("--owner", required=True, help="Repository owner")
    parser.add_argument("--repo", required=True, help="Repository name")
    parser.add_argument("--pull-number", required=True, type=int, help="PR number")
    parser.add_argument("--comment-id", required=True, type=int, help="First comment id of thread")
    parser.add_argument("--body-file", required=True, help="Reply body file, or - for stdin")
    parser.add_argument(
        "--human-checked",
        action="store_true",
        help="Append the human-checked signature to the reply",
    )
    args = parser.parse_args()

    body = read_body(args.body_file)
    if not body.strip():
        emit_error("empty_body", detail="Reply body is empty")
    if args.human_checked:
        body = sign(body)

    pull = f"repos/{args.owner}/{args.repo}/pulls/{args.pull_number}"
    endpoint = f"{pull}/comments/{args.comment_id}/replies"
    cmd = ["gh", "api", endpoint, "--method", "POST", "--input", "-"]
    result = subprocess.run(cmd, input=json.dumps({"body": body}), capture_output=True, text=True)

    if result.returncode != 0:
        emit_error(
            "gh_api_failed",
            detail="Failed to post reply via gh api",
            gh_exit_code=result.returncode,
            http_status=extract_http_status(result.stderr),
            stderr=result.stderr.strip(),
        )

    try:
        response_data = json.loads(result.stdout)
    except json.JSONDecodeError as error:
        emit_error(
            "invalid_api_response",
            detail=f"Failed to parse gh api response as JSON: {error}",
            stdout=result.stdout.strip(),
        )

    reply_id = response_data.get("id") if isinstance(response_data, dict) else None
    html_url = response_data.get("html_url") if isinstance(response_data, dict) else None
    if not isinstance(reply_id, int) or not isinstance(html_url, str):
        emit_error(
            "invalid_api_response",
            detail="API response missing required id or html_url fields",
            response=response_data,
        )

    print(json.dumps({"id": reply_id, "html_url": html_url}))


if __name__ == "__main__":
    main()
