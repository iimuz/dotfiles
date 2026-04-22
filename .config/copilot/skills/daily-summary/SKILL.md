---
name: daily-summary
description: >-
  Use when summarizing daily work activity into a report by analyzing
  Copilot session logs, GitHub activity (issues, PRs), and Atlassian
  activity (Jira issues, Confluence pages) for a specified date.
user-invocable: true
disable-model-invocation: false
---

# Daily Summary

## Overview

Generate a qualitative daily work summary from Copilot session logs,
GitHub activity (issues, PRs), and Atlassian activity (Jira issues,
Confluence pages). Scripts and MCP tools identify sessions and activities
for the target date, sub-agents analyze each source in parallel, then
the results are consolidated into a structured daily report that merges
overlapping items from all sources.

Atlassian activity is retrieved via Atlassian MCP tools. When MCP tools
are unavailable (not connected, authentication expired), Atlassian sources
are silently skipped and the report is generated from remaining sources.

Execution order: determine date -> identify sources (parallel) -> parallel
sub-agent analysis -> consolidate and merge -> save and present.

## Input

- `date: string` (optional): Target date in YYYY-MM-DD format. Interpreted
  in the execution environment's local timezone. Defaults to today.
- `end_date: string` (optional): End date for a range in YYYY-MM-DD format.
  Same timezone as `date`. Defaults to `date` when omitted.

## Output

- Per-session summaries saved to `{run_dir}/session-{uuid}.md`.
- Per-activity summaries saved to `{run_dir}/activity-{type}-{owner}-{repo}-{number}.md`.
- Per-Jira summaries saved to `{run_dir}/activity-jira-{key}.md`.
- Per-Confluence summaries saved to `{run_dir}/activity-confluence-{pageId}.md`.
- Consolidated report saved to `{run_dir}/{date}-daily-summary.md`.
- The summary content is also presented directly to the user.
- If the user requests saving to another location, copy the file accordingly.
- Run directory: `~/.copilot/session-state/{session_id}/files/{YYYYMMDDHHMMSS}-daily-summary/`.

## Operations

Derive `refs_dir` from the `Base directory` field in the skill-context header:
`refs_dir = {skill_base_dir}/references/`

### Stage 1: Determine Target Date

Resolve the target date from user input. If no date is specified, use today
in YYYY-MM-DD format (derive from the current datetime provided in the
conversation context, adjusted to the execution environment's local timezone).
If the user specifies a date range, set both `date` and `end_date`.

All dates are interpreted in the execution environment's local timezone.
Session timestamps (stored in UTC) are converted to local dates before
comparison. GitHub API queries are expanded to cover the corresponding UTC
range automatically.

### Stage 2: Identify Sources

Run scripts and MCP queries in parallel to collect all activity sources.
Stages 2a and 2b run via shell scripts. Stages 2c and 2d run via
Atlassian MCP tools. Launch all four discovery operations in parallel.

#### 2a: Identify Sessions

Run [`scripts/extract-sessions.sh`](scripts/extract-sessions.sh) with
`--date YYYY-MM-DD`. For date ranges, add `--end-date YYYY-MM-DD`.

The script scans `~/.copilot/session-state/` for sessions created within
the target date range. Empty sessions (no summary and small events file) are
excluded by default. Add `--include-empty` to include them for debugging.

Output is a JSON array of session metadata:

- `session_id`: UUID
- `session_path`: Absolute path to the session directory
- `created_at`: ISO 8601 timestamp
- `summary`: Session summary from workspace.yaml
- `cwd`: Working directory (repository path)
- `remote_url`: Git remote origin URL (empty if cwd is deleted or not a
  git repository)
- `owner_repo`: Parsed `owner/repo` from remote URL (e.g., `iimuz/dotfiles`).
  Empty if remote URL is unavailable. Use this field for deterministic
  repository matching with GitHub activity data.

#### 2b: Identify GitHub Activities

Run [`scripts/extract-activities.sh`](scripts/extract-activities.sh) with
`--date YYYY-MM-DD`. For date ranges, add `--end-date YYYY-MM-DD`.

The script queries GitHub via `gh search` to find issues and PRs the user
was involved with during the target period. Three queries are combined:
issues involved, PRs involved, and PRs reviewed. Results are deduplicated.

Output is a JSON array of activity metadata:

- `type`: `issue` or `pr`
- `number`: Issue or PR number
- `owner`: Repository owner
- `repo`: Repository name
- `title`: Issue or PR title
- `url`: GitHub URL
- `state`: Current state

#### 2c: Identify Jira Activities

Call the `atlassian-getAccessibleAtlassianResources` MCP tool to discover
the Atlassian cloud ID. Then call the `atlassian-atlassianUserInfo` MCP
tool to get the current user's account ID (needed by sub-agents to
identify the user's comments).

Search for Jira issues using the `atlassian-searchJiraIssuesUsingJql`
MCP tool with:

- `cloudId`: from `getAccessibleAtlassianResources`
- `jql`: `(assignee = currentUser() OR reporter = currentUser())
AND updated >= "{date} 00:00" AND updated <= "{end_date} 23:59"
ORDER BY updated DESC`
- `fields`: `["summary", "status", "issuetype", "project", "updated"]`
- `maxResults`: 50
- `responseContentFormat`: `markdown`

Normalize results into a metadata list. Each item contains:

- `source`: `jira`
- `key`: Jira issue key (e.g., `API-15`)
- `project_key`: Project key (e.g., `API`)
- `project_name`: Project display name
- `summary`: Issue summary
- `status`: Status name
- `type`: Issue type name
- `updated`: Last update timestamp
- `url`: `https://{site}/browse/{key}`
- `cloud_id`: Atlassian cloud ID

If any MCP call fails (tool not available, authentication expired, network
error), log the error to stderr and return an empty array. Do not fail the
entire workflow.

#### 2d: Identify Confluence Activities

Search for Confluence pages using the `atlassian-searchConfluenceUsingCql`
MCP tool with:

- `cloudId`: from `getAccessibleAtlassianResources` (reuse from 2c)
- `cql`: `contributor = currentUser() AND lastmodified >= "{date}" ORDER BY lastmodified DESC`
- `limit`: 50

Filter results to only include pages where `lastModified` falls within the
target date range (the CQL `lastmodified` filter does not support a range
upper bound, so post-filter on `end_date`).

Normalize results into a metadata list. Each item contains:

- `source`: `confluence`
- `page_id`: Content ID
- `title`: Page title
- `space_key`: Space key
- `space_name`: Space display name
- `last_modified`: Last modification timestamp
- `url`: Full page URL
- `excerpt`: Content excerpt
- `cloud_id`: Atlassian cloud ID

If any MCP call fails, log the error and return an empty array.

#### Handling Empty Results

If all outputs are empty arrays, inform the user that no sessions or
activities were found for the specified date and stop.

If only some sources have results, proceed with those sources alone.
Not all sources are required.

### Stage 3: Parallel Analysis

Create a run directory for intermediate outputs:
`~/.copilot/session-state/{session_id}/files/{YYYYMMDDHHMMSS}-daily-summary/`

Derive `{YYYYMMDDHHMMSS}` from the `current_datetime` in the conversation
context. Do not use shell command substitution (e.g., `$(date ...)`) inside
bash commands to generate timestamps.

Sub-agent task names must be kept under 25 characters to avoid agent ID
truncation. Use short patterns such as `session-{short_id}` (first 8 chars
of UUID) and `act-{number}` instead of encoding the full owner/repo/number.

Launch all sub-agents in parallel across all source types.

#### 3a: Session Sub-Agents

For each session from Stage 2a, launch a `general-purpose` sub-agent (`task()` with
`agent_type: "general-purpose"`, `model: "claude-sonnet-4.6"`) to analyze the session
in detail. Include `{refs_dir}/session-rules.md` in the prompt so the sub-agent knows
the output format and procedure.

Pass each sub-agent:

- `session_path`: from the Stage 2a output
- `output_filepath`: `{run_dir}/session-{session_id_being_analyzed}.md`

The sub-agent reads `{refs_dir}/session-rules.md` for the analysis procedure and
output format. Each sub-agent writes its summary as a markdown file to the specified
output path.

#### 3b: Activity Sub-Agents

For each activity from Stage 2b, launch a `general-purpose` sub-agent (`task()` with
`agent_type: "general-purpose"`, `model: "claude-sonnet-4.6"`) to analyze the issue
or PR in full. Include `{refs_dir}/activity-rules.md` in the prompt so the sub-agent
knows the output format and procedure.

Retrieve the authenticated GitHub username before launching activity
sub-agents:

```bash
gh api user --jq .login
```

Pass each sub-agent:

- `type`: `issue` or `pr`
- `owner`: Repository owner
- `repo`: Repository name
- `number`: Issue or PR number
- `date`: Start date of the target period
- `end_date`: End date of the target period
- `github_user`: Authenticated GitHub username
- `output_filepath`: `{run_dir}/activity-{type}-{owner}-{repo}-{number}.md`

The sub-agent reads `{refs_dir}/activity-rules.md` for the analysis procedure and
output format. Each sub-agent fetches the full issue/PR history, understands the
complete context, and produces a summary scoped to the user's activity within the
target period.

#### 3c: Jira Sub-Agents

For each Jira issue from Stage 2c, launch a `general-purpose` sub-agent (`task()` with
`agent_type: "general-purpose"`, `model: "claude-sonnet-4.6"`) to analyze the issue
in full. Include `{refs_dir}/jira-rules.md` in the prompt so the sub-agent knows the
output format and procedure.

Pass each sub-agent:

- `key`: Jira issue key
- `project_name`: Project display name
- `cloud_id`: Atlassian cloud ID (from Stage 2c)
- `date`: Start date of the target period
- `end_date`: End date of the target period
- `atlassian_user_id`: User account ID (from Stage 2c)
- `output_filepath`: `{run_dir}/activity-jira-{key}.md`

The sub-agent reads `{refs_dir}/jira-rules.md` for the analysis procedure and output
format. Each sub-agent fetches the full issue via Atlassian MCP tools and produces a
summary scoped to the user's activity within the target period.

#### 3d: Confluence Sub-Agents

For each Confluence page from Stage 2d, launch a `general-purpose` sub-agent (`task()` with
`agent_type: "general-purpose"`, `model: "claude-sonnet-4.6"`) to analyze the page content.
Include `{refs_dir}/confluence-rules.md` in the prompt so the sub-agent knows the output
format and procedure.

Pass each sub-agent:

- `page_id`: Confluence content ID
- `title`: Page title
- `space_key`: Space key
- `cloud_id`: Atlassian cloud ID (from Stage 2c)
- `date`: Start date of the target period
- `end_date`: End date of the target period
- `atlassian_user_id`: User account ID (from Stage 2c)
- `output_filepath`: `{run_dir}/activity-confluence-{page_id}.md`

The sub-agent reads `{refs_dir}/confluence-rules.md` for the analysis procedure and
output format. Each sub-agent fetches the full page content via Atlassian MCP tools
and produces a summary of the page and its relevance to the user's work.

#### Failure Handling

If a sub-agent fails, note the failure and continue with other items.
Do not retry failed sub-agents.

### Stage 4: Consolidate

Read all summary files from the run directory:

- Session summaries: `{run_dir}/session-*.md`
- GitHub activity summaries: `{run_dir}/activity-issue-*.md`, `{run_dir}/activity-pr-*.md`
- Jira activity summaries: `{run_dir}/activity-jira-*.md`
- Confluence activity summaries: `{run_dir}/activity-confluence-*.md`

Generate a consolidated markdown summary following the format defined in
[`references/output-format.md`](references/output-format.md).

Key synthesis tasks:

- Group completed items by repository or project, deduplicating same-task
  entries. Use repository name for GitHub items and project name for Jira
  items.
- Merge overlapping Copilot sessions and GitHub activities that refer to
  the same work. Use a tiered matching strategy: (1) match session
  `Related Issues`/`Related PRs` fields against activity numbers for
  high-confidence links, (2) match session `owner_repo` and branch name
  against activity repository and PR head ref, (3) fall back to text
  similarity in task descriptions. When merging, combine the context from
  both sources to write a richer description than either source alone
  provides.
- Merge overlapping Jira activities with Copilot sessions or GitHub
  activities when they refer to the same work. Indicators: Jira issue
  key mentioned in session events or GitHub PR/issue body, similar task
  descriptions, same repository referenced in Jira remote links.
- Integrate Confluence page summaries as context for related work items.
  Meeting notes that reference specific tasks or decisions should enrich
  the corresponding work item description. Standalone documentation work
  (page creation, significant updates) appears as its own completed item.
- When the same logical task spans multiple repositories or projects,
  group them into a single collective entry.
- Identify significant decisions across all sessions and activities,
  including decisions recorded in Confluence meeting notes.
- List open items with meaningful activity in the period as in-progress items.
- Exclude failed or abandoned sessions from completed items (mention
  them separately if relevant).
- Omit sessions and activities that produced no meaningful outcomes.

### Stage 5: Save and Present

Save the generated markdown to the run directory:
`{run_dir}/{date}-daily-summary.md`

Present the full summary content to the user. If the user requests saving
to an additional location, copy or write the file to the specified path.

## Examples

- Happy: user asks for today's summary, script finds 8 sessions across
  3 repositories, 5 GitHub activities (3 PRs, 2 issues), 3 Jira issues,
  and 2 Confluence pages; 18 parallel sub-agents produce summaries; 2
  sessions and PRs overlap and are merged, 1 Jira issue links to a GitHub
  PR and they are merged; the consolidated report groups work by repository
  and project, listing 9 completed items with 3 in-progress items and
  2 decisions.
- Session only: no GitHub or Atlassian activities found, proceeds with
  Copilot sessions alone.
- Activity only: no Copilot sessions found but GitHub and/or Atlassian
  activities exist, proceeds with activities alone.
- Atlassian unavailable: Atlassian MCP tools fail (not connected or
  authentication expired), Jira and Confluence sources are skipped with
  a logged warning, report is generated from Copilot sessions and GitHub
  activities only. Behaves like the original workflow.
- Empty: all sources return empty arrays, the user is informed that no
  sessions or activities were found.
- Partial failure: 1 of 18 sub-agents fails, the remaining 17 summaries
  are consolidated successfully with a note about the failed item.
