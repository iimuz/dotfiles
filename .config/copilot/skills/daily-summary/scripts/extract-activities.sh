#!/usr/bin/env bash
# Requires: bash 5+, jq, gh (authenticated)
#
# Identify GitHub activity (issues and PRs) for a specified date range.
# Outputs a JSON array of activity metadata to stdout.
# Full issue/PR details are fetched by sub-agents, not this script.
#
# Input dates are local timezone. The script converts them to a UTC date
# range for the GitHub API, expanding by one day to cover timezone boundaries.
set -euo pipefail

usage() {
  cat >&2 <<'EOF'
Usage: extract-activities.sh --date YYYY-MM-DD [--end-date YYYY-MM-DD] [--limit N]

Options:
  --date      Target date in YYYY-MM-DD format (required)
  --end-date  End date for range (optional, defaults to --date)
  --limit     Maximum results per query (optional, defaults to 100)
EOF
  exit 1
}

validate_date() {
  local -r value="$1" label="$2"
  if ! [[ "$value" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    echo "Error: $label must be in YYYY-MM-DD format" >&2
    exit 1
  fi
}

search_issues() {
  local -r date_range="$1" limit="$2"
  gh search issues \
    --involves=@me \
    --updated="$date_range" \
    --limit "$limit" \
    --json number,repository,title,url,state \
    2>/dev/null || echo "[]"
}

search_prs_involves() {
  local -r date_range="$1" limit="$2"
  gh search prs \
    --involves=@me \
    --updated="$date_range" \
    --limit "$limit" \
    --json number,repository,title,url,state \
    2>/dev/null || echo "[]"
}

search_prs_reviewed() {
  local -r date_range="$1" limit="$2"
  gh search prs \
    --reviewed-by=@me \
    --updated="$date_range" \
    --limit "$limit" \
    --json number,repository,title,url,state \
    2>/dev/null || echo "[]"
}

normalize_results() {
  local -r type_value="$1"
  jq -c --arg type "$type_value" '
    [.[] | {
      type: $type,
      number: .number,
      owner: (.repository.nameWithOwner | split("/")[0]),
      repo: (.repository.nameWithOwner | split("/")[1]),
      title: .title,
      url: .url,
      state: .state
    }]
  '
}

deduplicate() {
  jq -s '
    add
    | group_by(.type + ":" + .owner + "/" + .repo + ":#" + (.number | tostring))
    | map(.[0])
    | sort_by(.owner + "/" + .repo + ":#" + (.number | tostring))
  '
}

main() {
  local date="" end_date="" limit=100

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --date)
        [[ $# -ge 2 ]] || usage
        date="$2"
        shift 2
        ;;
      --end-date)
        [[ $# -ge 2 ]] || usage
        end_date="$2"
        shift 2
        ;;
      --limit)
        [[ $# -ge 2 ]] || usage
        limit="$2"
        shift 2
        ;;
      *)
        echo "Error: Unknown option: $1" >&2
        usage
        ;;
    esac
  done

  if [[ -z "$date" ]]; then
    echo "Error: --date is required" >&2
    usage
  fi

  validate_date "$date" "--date"
  end_date="${end_date:-$date}"
  validate_date "$end_date" "--end-date"

  if ! type gh >/dev/null 2>&1; then
    echo "Error: gh CLI is required but not found" >&2
    exit 1
  fi

  if ! type jq >/dev/null 2>&1; then
    echo "Error: jq is required but not found" >&2
    exit 1
  fi

  if ! gh auth status >/dev/null 2>&1; then
    echo "Error: gh CLI is not authenticated" >&2
    exit 1
  fi

  # Convert local date boundaries to UTC for the GitHub API.
  # Start of local start-date in UTC may be the previous day (e.g., JST+9).
  # End boundary is start of the day AFTER local end-date in UTC.
  local utc_start utc_end
  utc_start=$(date -u -d "$date" +%Y-%m-%d)
  utc_end=$(date -u -d "$end_date + 1 day" +%Y-%m-%d)
  local -r date_range="${utc_start}..${utc_end}"

  local issues_json prs_involves_json prs_reviewed_json
  issues_json=$(search_issues "$date_range" "$limit")
  prs_involves_json=$(search_prs_involves "$date_range" "$limit")
  prs_reviewed_json=$(search_prs_reviewed "$date_range" "$limit")

  local issues_normalized prs_normalized
  issues_normalized=$(echo "$issues_json" | normalize_results "issue")
  prs_normalized=$(
    echo "$prs_involves_json" "$prs_reviewed_json" |
      jq -s 'add' |
      normalize_results "pr"
  )

  echo "$issues_normalized" "$prs_normalized" | deduplicate
}

main "$@"
