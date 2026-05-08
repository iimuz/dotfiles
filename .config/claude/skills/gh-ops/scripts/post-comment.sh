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

  local -r allowed_params='--repo OWNER/REPO --issue NUMBER [--dry-run]'

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
def validate_detail:
  if type != "object" then
    fail("details[] must be objects")
  else
    .
  end
  | {
      label: (.label | require_non_empty_string("details[].label")),
      content: (.content | require_non_empty_string("details[].content"))
    }
  | if (.label | test("[<>]")) then
      fail("details[].label must not contain < or >")
    else
      .
    end;

if type != "object" then
  fail("input must be a JSON object")
else
  .
end
| {
    summary: (.summary | require_non_empty_string("summary")),
    details: (
      if .details == null then
        []
      elif (.details | type) != "array" then
        fail("details must be an array when provided")
      else
        .details | map(validate_detail)
      end
    )
  }
JQ
  )"
  local validated_json
  local validation_error

  local error_file
  error_file="$(mktemp)"
  trap "rm -f -- '$error_file'" EXIT

  if validated_json="$(printf '%s' "$input_json" | jq -ce "$validation_filter" 2>"$error_file")"; then
    rm -f "$error_file"
    printf '%s' "$validated_json"
    return 0
  fi

  validation_error="$(cat "$error_file")"
  rm -f "$error_file"
  # Clean up jq-specific prefixes for friendlier messages (raw text used as fallback)
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
  if [[ $# -ne 1 ]]; then
    printf '%s\n' 'Error: build_body expects exactly 1 argument' >&2
    return 1
  fi

  local -r validated_json="$1"
  local -r body_filter="$(
    cat <<'JQ'
.summary + (
  .details
  | map("\n\n<details>\n<summary>\(.label)</summary>\n\n\(.content)\n\n</details>")
  | join("")
)
JQ
  )"

  printf '%s' "$validated_json" | jq -r "$body_filter"
}

check_dependencies() {
  type jq >/dev/null 2>&1 || {
    print_error 'Error: jq is required but not found'
    exit 1
  }
}

main() {
  check_dependencies

  local repo=""
  local issue=""
  local dry_run=false

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --repo)
        [[ $# -ge 2 ]] || usage_error '--repo requires a value'
        repo="$2"
        shift 2
        ;;
      --issue)
        [[ $# -ge 2 ]] || usage_error '--issue requires a value'
        issue="$2"
        shift 2
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

  [[ -n "$repo" ]] || usage_error '--repo is required'
  [[ "$repo" =~ ^[a-zA-Z0-9._-]+/[a-zA-Z0-9._-]+$ ]] || usage_error '--repo must be in OWNER/REPO format'
  [[ -n "$issue" ]] || usage_error '--issue is required'
  [[ "$issue" =~ ^[0-9]+$ ]] || usage_error '--issue must be a number'

  local input_json
  input_json="$(cat)"

  local validated_json
  validated_json="$(validate_input_json "$input_json")"

  local body
  body="$(build_body "$validated_json")"

  if [[ "$dry_run" == true ]]; then
    printf '%s\n' '=== Preview (dry-run) ==='
    printf '%s\n' "Target: $repo#$issue"
    printf '%s\n' '=== Body ==='
    printf '%s\n' "$body"
    exit 0
  fi

  printf '%s\n' "$body" | gh issue comment "$issue" --repo "$repo" --body-file -
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
