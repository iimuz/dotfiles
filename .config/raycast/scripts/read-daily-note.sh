#!/usr/bin/env bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title View Daily Note
# @raycast.mode silent
# @raycast.packageName Utils
# @raycast.icon 🗓️

# Optional parameters:
# @raycast.argument1 { "type": "text", "placeholder": "Empty for Today, -1 for Yesterday, or YYYY-MM-DD", "optional": true }

set -Eeuo pipefail

SCRIPT_NAME=$(basename "${0}")
readonly SCRIPT_NAME

function log_info() {
  local _message="$1"
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] ($SCRIPT_NAME) [INFO] $_message" >&2
}

function log_error() {
  local _message="$1"
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] ($SCRIPT_NAME) [ERROR] $_message" >&2
}

function err() {
  log_error "Line $1: $2" >&2
  exit 1
}

function cleanup() {
  echo "no cleanup actions needed currently" >/dev/null
}

trap 'err ${LINENO} "$BASH_COMMAND"' ERR
trap cleanup EXIT

function usage() {
  cat <<EOF
Usage: ${SCRIPT_NAME} [OPTIONS]

Appends the currently selected text to a daily note at $HOME/daily_note/YYYYMMDD.md.

OPTIONS:
  -h, --help      Show this help message
  -v, --verbose   Enable verbose output

EXAMPLE:
  # Append selection to today's daily note
  $ ${SCRIPT_NAME}
EOF
}

function main() {
  local -r INPUT="${1:-}" # 表示する日付情報
  shift

  while [[ $# -gt 0 ]]; do
    case $1 in
    -h | --help)
      usage
      exit 0
      ;;
    -v | --verbose)
      set -x
      shift
      ;;
    *)
      log_error "Unknown option: $1"
      usage
      exit 1
      ;;
    esac
  done

  # 設定
  local -r TARGET_DIR="$HOME/daily_note"
  local -r DATE_FORMAT="%Y%m%d"
  local -r EXT=".md"

  # 対象とするDaily Noteの日付計算
  # - 引数なし: 今日
  # - 相対日付入力(-1, +1): n日分ずらす
  # - 直接入力(YYYY-MM-DD等): そのまま使用
  target_date="$(date +%Y%m%d)"
  if [ -z "$INPUT" ]; then
    target_date=$(date +"$DATE_FORMAT")
  elif [[ "$INPUT" =~ ^[-+]?[0-9]+$ ]]; then
    target_date=$(date -v"${INPUT}d" +"$DATE_FORMAT")
  else
    target_date="$INPUT"
  fi
  local -r TARGET_FILE="$TARGET_DIR/$target_date$EXT"

  local -r TEMP_HTML="/tmp/raycast_note_render.html"
  if [ ! -f "$TARGET_FILE" ]; then
    log_warn "$target_date のファイルが見つかりません"
    return 1
  fi

  # HTMLラップ（ブラウザでのレンダリング用）
  local -r CONTENT=$(cat "$TARGET_FILE")
  # Pre-escape content for safe embedding inside JS template literal in the HTML
  local -r CONTENT_ESCAPED=$(printf '%s' "$CONTENT" | sed 's/\\/\\\\/g; s/`/\\`/g; s/\$/\\$/g')
  cat <<EOF >"$TEMP_HTML"
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>$target_date</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/github-markdown-css/5.2.0/github-markdown.min.css">
  <script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
  <style>
    .markdown-body { box-sizing: border-box; min-width: 200px; max-width: 980px; margin: 0 auto; padding: 45px; }
  </style>
</head>
<body class="markdown-body">
  <div id="content"></div>
  <script>
    // JSのテンプレートリテラル内のエスケープ処理
    const rawContent = \`$CONTENT_ESCAPED\`;
    document.getElementById('content').innerHTML = marked.parse(rawContent);
  </script>
</body>
</html>
EOF

  open "$TEMP_HTML"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
