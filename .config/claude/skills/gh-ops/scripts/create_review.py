#!/usr/bin/env python3
import argparse
import json
import re
import subprocess
import sys
from dataclasses import dataclass
from typing import Any, NoReturn

__all__ = ["main"]


@dataclass(frozen=True)
class ReviewResult:
    id: int
    html_url: str

    def to_json(self) -> str:
        return json.dumps({"id": self.id, "html_url": self.html_url})


def extract_http_status(stderr_text: str) -> int | None:
    match = re.search(r"HTTP\s+(\d{3})", stderr_text)
    if match is None:
        return None
    return int(match.group(1))


def emit_error(message: str, *, exit_code: int = 1, **details: Any) -> NoReturn:
    error_payload = {"error": message, **details}
    print(json.dumps(error_payload), file=sys.stderr)
    sys.exit(exit_code)


def main() -> None:
    """
    Parses arguments, constructs a JSON payload, and calls the GitHub API
    to create a pending review.
    """
    parser = argparse.ArgumentParser(description="Create a pending PR review.")
    parser.add_argument("--owner", required=True, help="Repository owner")
    parser.add_argument("--repo", required=True, help="Repository name")
    parser.add_argument("--pull-number", required=True, type=int, help="PR number")
    parser.add_argument("--summary-body", required=True, help="Review summary body")
    parser.add_argument("--comments-json", required=True, help="JSON string of comments array")

    args = parser.parse_args()

    try:
        raw_comments = json.loads(args.comments_json)
    except json.JSONDecodeError as e:
        emit_error("invalid_comments_json", detail=f"Invalid JSON in --comments-json: {e}")

    if not isinstance(raw_comments, list):
        emit_error("invalid_comments_json", detail="--comments-json must be a JSON array")

    api_comments = []
    for index, comment in enumerate(raw_comments):
        if not isinstance(comment, dict):
            emit_error(
                "invalid_comment",
                detail=f"Comment at index {index} must be an object",
            )

        body = comment.get("body", "")
        suggestion = comment.get("suggestion")
        path = comment.get("path")
        line = comment.get("line")
        start_line = comment.get("start_line")
        side = comment.get("side", "RIGHT")

        if not path or line is None:
            emit_error(
                "invalid_comment_location",
                detail=f"Comment at index {index} is missing required path or line",
            )

        # Append suggestion block if present
        if suggestion:
            if "```" in suggestion:
                emit_error(
                    "invalid_suggestion_content",
                    detail=(
                        f"Comment at index {index} suggestion must not contain triple backticks"
                    ),
                )
            suggestion_block = f"\n\n```suggestion\n{suggestion}\n```"
            body += suggestion_block

        try:
            parsed_line = int(line)
        except (TypeError, ValueError):
            emit_error(
                "invalid_comment_location",
                detail=f"Comment at index {index} has non-integer line: {line}",
            )

        # Construct API comment object
        api_comment = {"path": path, "body": body, "line": parsed_line, "side": side}

        if start_line:
            try:
                api_comment["start_line"] = int(start_line)
            except (TypeError, ValueError):
                emit_error(
                    "invalid_comment_location",
                    detail=(f"Comment at index {index} has non-integer start_line: {start_line}"),
                )

        api_comments.append(api_comment)

    # Construct payload for GitHub API
    payload = {"body": args.summary_body, "comments": api_comments}
    # event is OMITTED to create a PENDING review

    # Call gh api
    endpoint = f"repos/{args.owner}/{args.repo}/pulls/{args.pull_number}/reviews"
    json_payload = json.dumps(payload)

    cmd = ["gh", "api", endpoint, "--method", "POST", "--input", "-"]

    result = subprocess.run(cmd, input=json_payload, capture_output=True, text=True)

    if result.returncode != 0:
        emit_error(
            "gh_api_failed",
            detail="Failed to create pending review via gh api",
            exit_code=1,
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

    review_id = response_data.get("id")
    html_url = response_data.get("html_url")
    if not isinstance(review_id, int) or not isinstance(html_url, str):
        emit_error(
            "invalid_api_response",
            detail="API response missing required id or html_url fields",
            response=response_data,
        )

    print(ReviewResult(id=review_id, html_url=html_url).to_json())


if __name__ == "__main__":
    main()
