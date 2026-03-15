---
name: aws-cli-log-retrieval
description: Retrieve and analyze CloudWatch Logs with AWS CLI.
user-invocable: false
disable-model-invocation: false
---

# AWS CLI Log Retrieval

## Overview

This skill provides CloudWatch Logs retrieval best practices for a subagent using AWS CLI.
The subagent receives `run_dir`, `profile`, `region`, and `investigation_context`, then
autonomously decides which log groups to query, what time ranges to search, what filter patterns
to apply, and when to stop, narrow the search, or pivot to another source of evidence.
Verify AWS access before retrieval, save retrieval results under `run_dir` before analysis, and
return only a concise summary plus artifact paths instead of raw log content.

## Input

- `run_dir: string` (required): Directory where retrieval artifacts are written before analysis.
- `profile: string` (required): AWS CLI profile used for identity checks and log retrieval.
- `region: string` (required): AWS region the subagent investigates.
- `investigation_context: string` (required): Investigation details, clues, and searchable terms
  that can guide log group choice, time-range selection, and filter-pattern refinement.

## Output

- `summary: string` (required): Concise result describing investigated scope, filter decisions,
  findings, and the saved artifact paths under `run_dir`.
- `saved_paths: readonly string[]` (required): Artifact paths written under `run_dir`, including
  stable single-window files and paginated page files when needed.
- `resolved: boolean` (required): Whether the saved evidence identifies a likely root cause or
  confirms no matching events across the full investigated scope.

## Best Practices

### Access Verification

- Run `aws sts get-caller-identity --profile <profile> --output json` before any retrieval work.
- Stop on unrecoverable AWS CLI errors such as auth failures, permission denials, or malformed
  requests instead of continuing with partial assumptions.
- Use `investigation_context` to decide whether to confirm candidate log groups early, but do not
  start log retrieval until access verification succeeds.

### Retrieval

- Decide log groups and time ranges from `investigation_context`, then keep every
  `aws logs filter-log-events` query within a 15-minute window.
- When converting chosen timestamps to epoch milliseconds, use
  `date -j -f "%Y-%m-%dT%H:%M:%S" "<timestamp>" "+%s000"` on macOS and
  `date -d "<timestamp>" "+%s000"` on Linux.
- Always use `--output json` for retrieval commands so saved artifacts stay machine-readable.
- Apply `--filter-pattern` when `investigation_context` provides searchable terms such as request
  IDs, error codes, usernames, or stable message fragments.
- Handle pagination by following `nextToken` until it is absent for the current window.
- If one window returns 1000 or more events across pages, narrow the time window or tighten the
  filter pattern before spending more retrieval volume on the same scope.
- If one window returns 0 events, relax the filter pattern when justified by the context, or move
  on to another window or log group instead of repeating the same empty query.

### Artifact Storage

- Save every retrieval artifact to `run_dir` before analysis begins.
- Use stable file names such as `{run_dir}/{sanitized-log-group}-{start_ms}-{end_ms}.json` for
  single-window results and `{run_dir}/{sanitized-log-group}-{start_ms}-{end_ms}-page-001.json`
  for paginated results.
- Sanitize log group names by replacing `/` with `-` before composing file names.
- Save separate page files so each artifact remains valid JSON without concatenation.
- Never overwrite an existing artifact; add a numeric suffix when a stable name already exists.
- Keep every saved file valid JSON so later analysis can be repeated safely from disk.

### Analysis and Summary

- Analyze only the artifacts already saved in `run_dir`, and pivot the investigation only after
  recorded evidence shows the current scope is exhausted or unhelpful.
- Set `resolved: true` only when the saved evidence identifies a likely root cause or confirms no
  matching events across the full investigated scope.
- Keep `resolved: false` when the search covered only part of the plausible scope or when the
  evidence is incomplete, ambiguous, or contradictory.
- Return `summary`, `saved_paths`, and `resolved` as the complete output contract.
- Reference saved artifact paths in `summary` instead of returning raw log lines or large event
  payloads.

## Examples

- Happy: Access is verified, queries save JSON artifacts, and `summary` references `saved_paths` with `resolved: true`.
- Failure: `aws sts get-caller-identity` fails, so retrieval stops and returns `resolved: false` with no raw logs.
