---
name: aws-cli-log-retrieval
description: Retrieve and analyze CloudWatch Logs with AWS CLI.
user-invocable: false
disable-model-invocation: false
---

# AWS CLI Log Retrieval

## Overview

This knowledge/transform skill provides procedures for a subagent to follow when retrieving and
analyzing CloudWatch Logs with AWS CLI.

Execution order: verify_access -> convert_timestamps -> retrieve_logs -> save_results ->
analyze_results -> generate_summary.

Follow the procedures in that exact order. Stop at the first unrecoverable AWS access failure,
command timeout, or invalid time range.

## Schema

```typescript
interface AwsCliLogRetrievalInput {
  run_dir: string;
  log_groups: readonly string[];
  profile: string;
  region: string;
  time_range: {
    start: string;
    end: string;
  };
  investigation_context: string;
}

interface AwsCliLogRetrievalOutput {
  summary: string;
  saved_paths: readonly string[];
  resolved: boolean;
}
```

## Procedures

### Verify Access (verify_access)

Run access checks before any timestamp conversion or log retrieval.

- Run `aws sts get-caller-identity --profile <profile> --output json`.
- Run
  `aws logs describe-log-groups --log-group-name-prefix <log-group> --region <region> --profile <profile> --output json`
  for each requested log group.
- Confirm every requested log group is present in the command output before continuing.
- If either command fails, stop immediately and return a failure summary that names the failed
  command and includes the error message.

### Convert Timestamps (convert_timestamps)

Convert the requested time range to epoch milliseconds and split it into bounded retrieval windows.

- Convert `time_range.start` and `time_range.end` to epoch milliseconds.
- On macOS, run `date -j -f "%Y-%m-%dT%H:%M:%S" "<timestamp>" "+%s000"`.
- On Linux, run `date -d "<timestamp>" "+%s000"`.
- Confirm `start_ms < end_ms`. If not, stop and return a failure summary.
- Split the range into sequential windows no longer than 15 minutes each before any retrieval call.

### Retrieve Logs (retrieve_logs)

Run bounded `filter-log-events` queries for each log group and time window.

- Always use `--output json` in every retrieval command.
- Use `--filter-pattern <pattern>` whenever `investigation_context` provides searchable terms.
  This reduces data volume and improves retrieval speed.
- For each log group and each bounded window, run `aws logs filter-log-events` with
  `--log-group-name <log-group>`, `--start-time <start_ms>`, `--end-time <end_ms>`,
  `--region <region>`, `--profile <profile>`, `--filter-pattern <pattern>`, and
  `--output json`.
- After each call, inspect the JSON response for `nextToken`.
- If `nextToken` is present, rerun the same command with `--next-token <value>`.
- Continue paging until `nextToken` is absent.
- If one 15-minute window returns 1000 or more events across all pages, split that window into
  smaller windows or tighten the filter pattern before broadening the search.
- If one 15-minute window returns 0 events, do not rerun the unchanged query. Either relax the
  filter pattern once, if justified by the investigation, or continue to the next planned window.

### Save Results (save_results)

Persist retrieval output under `run_dir` using stable file names.

- Save single-page results as `{run_dir}/{sanitized-log-group}-{start_ms}-{end_ms}.json`.
- Save paginated results as
  `{run_dir}/{sanitized-log-group}-{start_ms}-{end_ms}-page-001.json`,
  `{run_dir}/{sanitized-log-group}-{start_ms}-{end_ms}-page-002.json`, and so on.
- Prefer separate page files so every saved artifact remains valid JSON.
- If you must append multiple pages to one file, append newline-delimited JSON documents and record
  that choice in the summary.
- Sanitize the log group name by replacing `/` with `-` and removing leading hyphens.
- Never overwrite an existing file. Add a numeric suffix if a collision occurs.

### Analyze Results (analyze_results)

Review the saved artifacts and extract evidence relevant to the investigation.

- Read saved files in chronological order across all requested log groups.
- Identify timestamps, error codes, request IDs, and repeated messages that match
  `investigation_context`.
- Set `resolved` to `true` only when the saved evidence identifies a likely root cause or confirms
  that no matching events exist across every requested log group and bounded window.
- Set `resolved` to `false` when evidence is incomplete, conflicting, or absent in only part of
  the requested scope.

### Generate Summary (generate_summary)

Return a concise result that can be used without re-reading raw logs.

- Summarize the log groups searched, the time range examined, and the filter pattern used.
- Include the main findings, the saved file paths, and the `resolved` decision.
- Refer to saved artifacts by path instead of quoting raw log lines.

## Session Files

| File                                                 | Written By     | Read By           |
| ---------------------------------------------------- | -------------- | ----------------- |
| `{run_dir}/{name}-{start_ms}-{end_ms}.json`          | `save_results` | `analyze_results` |
| `{run_dir}/{name}-{start_ms}-{end_ms}-page-001.json` | `save_results` | `analyze_results` |

## Constraints

- Keep the execution order exactly as documented in the Overview section.
- Limit every `filter-log-events` request to a maximum 15-minute window.
- Use only the provided `run_dir`, `log_groups`, `profile`, `region`, `time_range`, and
  `investigation_context` inputs.
- Save all retrieval artifacts under `run_dir`.
- Never return raw log content in the final output.
- Stop immediately after an AWS access failure, invalid time range, or retrieval timeout.

## Examples

### Happy Path

- A subagent receives `run_dir`, two `log_groups`, a valid `profile`, and a one-hour `time_range`.
- The subagent verifies access, converts timestamps, retrieves paginated results with
  `--output json`, and saves four page files.
- Analysis finds repeated timeout errors, and the summary returns the saved paths with
  `resolved: true`.

### Failure Path

- A subagent receives an expired `profile` for one requested region.
- `aws sts get-caller-identity --profile <profile> --output json` fails during `verify_access`.
- The subagent stops immediately and returns a failure summary without running any retrieval
  commands.
