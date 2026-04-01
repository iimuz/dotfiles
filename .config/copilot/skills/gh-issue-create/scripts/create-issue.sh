#!/usr/bin/env bash
set -euo pipefail

print_error() {
  if [[ $# -ne 1 ]]; then
    printf '%s\n' 'Error: print_error expects exactly 1 argument' >&2
    return 1
  fi

  printf '%s\n' "$1" >&2
}

usage_error() {
  if [[ $# -ne 1 ]]; then
    printf '%s\n' 'Error: usage_error expects exactly 1 argument' >&2
    return 1
  fi

  local -r allowed_params='--type TYPE [--repo OWNER/REPO] [--labels L1,L2] [--assignees A1,A2] [--project NAME] [--json] [--dry-run]'

  print_error "Error: $1"
  print_error "Allowed parameters: $allowed_params"
  exit 1
}

validate_input_json() {
  if [[ $# -ne 1 ]]; then
    printf '%s\n' 'Error: validate_input_json expects exactly 1 argument' >&2
    return 1
  fi

  local -r input_json="$1"
  local -r validation_filter="$(
    cat <<'JQ'
def fail(message): message | halt_error(1);
def require_non_empty_string(field_name):
  if type != "string" or length == 0 then
    fail(field_name + " must be a non-empty string")
  else
    .
  end;
def optional_string(field_name):
  if . == null then
    ""
  elif type != "string" then
    fail(field_name + " must be a string when provided")
  else
    .
  end;

if type != "object" then
  fail("input must be a JSON object")
else
  .
end
| {
    title: (.title | require_non_empty_string("title")),
    overview: (.overview | optional_string("overview")),
    details: (.details | optional_string("details")),
    goal: (.goal | optional_string("goal")),
    notes: (.notes | optional_string("notes")),
    related_urls: (.related_urls | optional_string("related_urls"))
  }
JQ
  )"
  local validated_json
  local error_file
  error_file="$(mktemp)"

  if validated_json="$(printf '%s' "$input_json" | jq -ce "$validation_filter" 2>"$error_file")"; then
    rm -f -- "$error_file"
    printf '%s' "$validated_json"
    return 0
  fi

  local validation_error
  validation_error="$(cat "$error_file")"
  rm -f -- "$error_file"
  validation_error="$(printf '%s' "$validation_error" | tr '\n' ' ' | sed -E \
    -e 's/^jq: error \(at <stdin>:[0-9]+\): //' \
    -e 's/^parse error: /invalid JSON: /' \
    -e 's/[[:space:]]+$//')"

  if [[ -z "$validation_error" ]]; then
    print_error 'Error: invalid input JSON'
  else
    print_error "Error: $validation_error"
  fi

  return 1
}

build_body() {
  if [[ $# -ne 2 ]]; then
    printf '%s\n' 'Error: build_body expects exactly 2 arguments' >&2
    return 1
  fi

  local -r validated_json="$1"
  local -r issue_type="$2"
  local -r body_filter="$(
    cat <<'JQ'
def section(header; content):
  if content | length > 0 then
    "## " + header + "\n\n" + content
  else
    "## " + header
  end;

if $type == "product-backlog" then
  [
    section("Overview"; .overview),
    section("Details"; .details),
    section("Goal"; .goal),
    section("Notes"; .notes)
  ] | join("\n\n")
elif $type == "feature" then
  [
    section("Related URLs"; .related_urls),
    section("Goal"; .goal),
    section("Details"; .details)
  ] | join("\n\n")
else
  "unknown type: " + $type | halt_error(1)
end
JQ
  )"

  printf '%s' "$validated_json" | jq -r --arg type "$issue_type" "$body_filter"
}

check_dependencies() {
  type jq >/dev/null 2>&1 || {
    print_error 'Error: jq is required but not found'
    exit 1
  }
  type gh >/dev/null 2>&1 || {
    print_error 'Error: gh is required but not found'
    exit 1
  }
}

main() {
  check_dependencies

  local issue_type=""
  local repo=""
  local labels=""
  local assignees=""
  local project=""
  local json_output=false
  local dry_run=false

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --type)
        [[ $# -ge 2 ]] || usage_error '--type requires a value'
        issue_type="$2"
        shift 2
        ;;
      --repo)
        [[ $# -ge 2 ]] || usage_error '--repo requires a value'
        repo="$2"
        shift 2
        ;;
      --labels)
        [[ $# -ge 2 ]] || usage_error '--labels requires a value'
        labels="$2"
        shift 2
        ;;
      --assignees)
        [[ $# -ge 2 ]] || usage_error '--assignees requires a value'
        assignees="$2"
        shift 2
        ;;
      --project)
        [[ $# -ge 2 ]] || usage_error '--project requires a value'
        project="$2"
        shift 2
        ;;
      --json)
        json_output=true
        shift
        ;;
      --dry-run)
        dry_run=true
        shift
        ;;
      *)
        usage_error "unknown parameter: $1"
        ;;
    esac
  done

  [[ -n "$issue_type" ]] || usage_error '--type is required'
  [[ "$issue_type" == "product-backlog" || "$issue_type" == "feature" ]] ||
    usage_error '--type must be product-backlog or feature'
  if [[ -n "$repo" ]]; then
    [[ "$repo" =~ ^[a-zA-Z0-9._-]+/[a-zA-Z0-9._-]+$ ]] ||
      usage_error '--repo must be in OWNER/REPO format'
  fi

  local input_json
  input_json="$(cat)"

  local validated_json
  validated_json="$(validate_input_json "$input_json")"

  local title
  title="$(printf '%s' "$validated_json" | jq -r '.title')"

  local body
  body="$(build_body "$validated_json" "$issue_type")"

  if [[ "$dry_run" == true ]]; then
    printf '%s\n' '=== Preview (dry-run) ==='
    printf '%s\n' "Type: $issue_type"
    printf '%s\n' "Title: $title"
    [[ -n "$repo" ]] && printf '%s\n' "Repo: $repo"
    [[ -n "$labels" ]] && printf '%s\n' "Labels: $labels"
    [[ -n "$assignees" ]] && printf '%s\n' "Assignees: $assignees"
    [[ -n "$project" ]] && printf '%s\n' "Project: $project"
    printf '%s\n' '=== Body ==='
    printf '%s\n' "$body"
    exit 0
  fi

  local -a gh_args=()
  gh_args+=(--title "$title")
  gh_args+=(--body-file -)

  if [[ -n "$repo" ]]; then
    gh_args+=(--repo "$repo")
  fi

  if [[ -n "$labels" ]]; then
    local IFS=','
    local -a label_array
    read -ra label_array <<<"$labels"
    local label
    for label in "${label_array[@]}"; do
      gh_args+=(--label "$label")
    done
  fi

  if [[ -n "$assignees" ]]; then
    local IFS=','
    local -a assignee_array
    read -ra assignee_array <<<"$assignees"
    local assignee
    for assignee in "${assignee_array[@]}"; do
      gh_args+=(--assignee "$assignee")
    done
  fi

  if [[ -n "$project" ]]; then
    gh_args+=(--project "$project")
  fi

  local url
  url="$(printf '%s\n' "$body" | gh issue create "${gh_args[@]}")"

  if [[ "$json_output" == true ]]; then
    local number
    number="$(printf '%s' "$url" | grep -oE '[0-9]+$')"
    printf '{"number":%s,"url":"%s"}\n' "$number" "$url"
  else
    printf '%s\n' "$url"
  fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
