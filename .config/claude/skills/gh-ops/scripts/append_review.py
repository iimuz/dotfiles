#!/usr/bin/env python3
import argparse
import json
import subprocess
import sys
from typing import Any, NoReturn

__all__ = ["main"]

PENDING_REVIEW_QUERY = """
query($owner: String!, $repo: String!, $number: Int!) {
  repository(owner: $owner, name: $repo) {
    pullRequest(number: $number) {
      reviews(first: 100, states: [PENDING]) {
        nodes { id viewerDidAuthor }
      }
    }
  }
}
"""

ADD_THREAD_MUTATION = """
mutation($reviewId: ID!, $path: String!, $body: String!, $line: Int!,
         $side: DiffSide!, $startLine: Int, $startSide: DiffSide) {
  addPullRequestReviewThread(input: {
    pullRequestReviewId: $reviewId, path: $path, body: $body, line: $line,
    side: $side, startLine: $startLine, startSide: $startSide
  }) {
    thread { id }
  }
}
"""


def emit_error(message: str, *, exit_code: int = 1, **details: Any) -> NoReturn:
    error_payload = {"error": message, **details}
    print(json.dumps(error_payload), file=sys.stderr)
    sys.exit(exit_code)


def run_graphql(query: str, variables: dict[str, Any]) -> dict[str, Any]:
    payload = json.dumps({"query": query, "variables": variables})
    cmd = ["gh", "api", "graphql", "--input", "-"]
    result = subprocess.run(cmd, input=payload, capture_output=True, text=True)
    if result.returncode != 0:
        emit_error(
            "gh_api_failed",
            detail="Failed to call gh api graphql",
            gh_exit_code=result.returncode,
            stderr=result.stderr.strip(),
        )
    try:
        response = json.loads(result.stdout)
    except json.JSONDecodeError as error:
        emit_error(
            "invalid_api_response",
            detail=f"Failed to parse graphql response as JSON: {error}",
            stdout=result.stdout.strip(),
        )
    if "errors" in response:
        emit_error("graphql_error", detail="GraphQL returned errors", errors=response["errors"])
    data = response.get("data")
    if not isinstance(data, dict):
        emit_error("invalid_api_response", detail="GraphQL response missing data")
    return data


def find_pending_review_id(owner: str, repo: str, pull_number: int) -> str | None:
    variables = {"owner": owner, "repo": repo, "number": pull_number}
    data = run_graphql(PENDING_REVIEW_QUERY, variables)
    repository = data.get("repository") or {}
    pull_request = repository.get("pullRequest") or {}
    nodes = (pull_request.get("reviews") or {}).get("nodes") or []
    for review in nodes:
        if isinstance(review, dict) and review.get("viewerDidAuthor"):
            review_id = review.get("id")
            if isinstance(review_id, str):
                return review_id
    return None


def build_comments(comments_json: str) -> list[dict[str, Any]]:
    try:
        raw_comments = json.loads(comments_json)
    except json.JSONDecodeError as error:
        emit_error("invalid_comments_json", detail=f"Invalid JSON in --comments-json: {error}")
    if not isinstance(raw_comments, list):
        emit_error("invalid_comments_json", detail="--comments-json must be a JSON array")
    comments: list[dict[str, Any]] = []
    for index, comment in enumerate(raw_comments):
        if not isinstance(comment, dict):
            emit_error("invalid_comment", detail=f"Comment at index {index} must be an object")
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
        if suggestion:
            if "```" in suggestion:
                emit_error(
                    "invalid_suggestion_content",
                    detail=(
                        f"Comment at index {index} suggestion must not contain triple backticks"
                    ),
                )
            body += f"\n\n```suggestion\n{suggestion}\n```"
        try:
            parsed_line = int(line)
        except (TypeError, ValueError):
            emit_error(
                "invalid_comment_location",
                detail=f"Comment at index {index} has non-integer line: {line}",
            )
        normalized: dict[str, Any] = {"path": path, "body": body, "line": parsed_line, "side": side}
        if start_line is not None:
            try:
                normalized["start_line"] = int(start_line)
            except (TypeError, ValueError):
                emit_error(
                    "invalid_comment_location",
                    detail=(f"Comment at index {index} has non-integer start_line: {start_line}"),
                )
        comments.append(normalized)
    return comments


def thread_variables(review_id: str, comment: dict[str, Any]) -> dict[str, Any]:
    start_line = comment.get("start_line")
    side = comment["side"]
    variables: dict[str, Any] = {
        "reviewId": review_id,
        "path": comment["path"],
        "body": comment["body"],
        "line": comment["line"],
        "side": side,
    }
    if start_line is not None:
        variables["startLine"] = int(start_line)
        variables["startSide"] = side
    return variables


def main() -> None:
    """Append comments to the viewer's existing pending review on a PR."""
    parser = argparse.ArgumentParser(description="Append comments to a pending PR review.")
    parser.add_argument("--owner", required=True, help="Repository owner")
    parser.add_argument("--repo", required=True, help="Repository name")
    parser.add_argument("--pull-number", required=True, type=int, help="PR number")
    parser.add_argument("--comments-json", required=True, help="JSON string of comments array")

    args = parser.parse_args()

    comments = build_comments(args.comments_json)
    if not comments:
        emit_error(
            "invalid_comments_json",
            detail="--comments-json must contain at least one comment",
        )

    review_id = find_pending_review_id(args.owner, args.repo, args.pull_number)
    if review_id is None:
        emit_error(
            "no_pending_review",
            detail="No pending review found. Use create_review.sh to create one first.",
        )

    thread_ids: list[str] = []
    for comment in comments:
        data = run_graphql(ADD_THREAD_MUTATION, thread_variables(review_id, comment))
        thread = (data.get("addPullRequestReviewThread") or {}).get("thread") or {}
        thread_id = thread.get("id")
        if not isinstance(thread_id, str):
            emit_error("invalid_api_response", detail="Mutation response missing thread id")
        thread_ids.append(thread_id)

    print(json.dumps({"review_id": review_id, "added": len(thread_ids), "thread_ids": thread_ids}))


if __name__ == "__main__":
    main()
