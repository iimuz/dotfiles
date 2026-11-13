#!/usr/bin/env bash
#
# macOS のパッケージを更新し、キャッシュを掃除する。
#
# 再起動の後、ほかのアプリを開く前にターミナルから実行する。
# brew が sudo を求めることがあり、下で掃除するキャッシュを使うプロセスがまだ動いていないため。

set -eu
set -o pipefail

STAMP_FILE="$HOME/.local/state/dotfiles/update-mac-weekly-cleanup"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# mise は今のディレクトリの mise.toml からツールを解決する。
# 呼び出し元に未インストールのバージョンを固定したものや未信頼のものがあると、掃除の前に止まるため。
cd "$HOME"

show_free_space() {
  echo "Free space $1:"
  df -h "$HOME"
}

update_tools() {
  brew update
  brew upgrade
  # --no-mas を外さない。Brewfile は App Store のアプリを挙げていないので、mas があると --force がそれらを全部消す。
  brew bundle cleanup --force --no-mas --file="$SCRIPT_DIR/.config/homebrew/Brewfile"
  # リポジトリの mise.toml が .env から GH_CONFIG_DIR を個人の gh の設定に解決するよう、リポジトリで実行する。
  (cd "$SCRIPT_DIR" && mise exec -- gh extension upgrade --all)
}

# 消す場所は XDG_* や各ツールの設定から読まず、$HOME の下で名指しする。
# ターミナルの値は別の場所を指すことがあり、ターミナルとターミナルの外の両方の場所を消す必要があるため。
clean_every_run() {
  mise prune -y
  if [ -d "$HOME/.cache/uv" ]; then
    uv cache prune --cache-dir "$HOME/.cache/uv"
  fi
  # npm はキャッシュのディレクトリが無いと作ってしまう
  for dir in "$HOME/.cache/npm-arm64" "$HOME/.npm"; do
    if [ -d "$dir" ]; then
      npm cache verify --cache "$dir"
    fi
  done
}

# 週 1 回の掃除は、曜日ではなく前回の成功からの日数で決める。
# 再起動の後に手で実行するので決まった曜日には動かず、失敗した回は次の実行でやり直す必要があるため。
weekly_cleanup_due() {
  local last
  if [ ! -f "$STAMP_FILE" ]; then
    return 0
  fi
  last=$(cat "$STAMP_FILE")
  if [[ ! "$last" =~ ^[1-9][0-9]*$ ]]; then
    return 0
  fi
  [ $(($(date +%s) - last)) -ge $((7 * 86400)) ]
}

# pnpm のストアは prune せず丸ごと消す。
# この環境の pnpm はファイルを複製 (clone) で置くので、`pnpm store prune` は今あるプロジェクトが使うパッケージまで消すため。
clean_weekly() {
  rm -rf "$HOME/.local/share/pnpm/store" "$HOME/Library/pnpm/store" \
    "$HOME/.cache/pnpm" "$HOME/Library/Caches/pnpm"
  if [ -d "$HOME/go/pkg/mod" ]; then
    GOMODCACHE="$HOME/go/pkg/mod" go clean -modcache
  fi
  if [ -d "$HOME/.cache/uv" ]; then
    uv cache clean --cache-dir "$HOME/.cache/uv"
  fi
  for dir in "$HOME/.cache/npm-arm64" "$HOME/.npm"; do
    rm -rf "$dir/_cacache" "$dir/_npx"
  done
  for dir in "$HOME/.cache/mise" "$HOME/Library/Caches/mise"; do
    if [ -d "$dir" ]; then
      MISE_CACHE_DIR="$dir" mise cache clear
    fi
  done
  rm -rf "$HOME/Library/Caches/gopls" "$HOME/Library/Caches/goimports" \
    "$HOME/Library/Caches/node-gyp" "$HOME/Library/Caches/golangci-lint" \
    "$HOME/Library/Caches/dprint" "$HOME/.cache/pip"
}

record_weekly_cleanup() {
  mkdir -p "$(dirname "$STAMP_FILE")"
  date +%s >"$STAMP_FILE"
}

show_free_space before
update_tools
clean_every_run
# 条件の中では set -e が効かないので、条件には判定だけを置く
if weekly_cleanup_due; then
  clean_weekly
  record_weekly_cleanup
fi
show_free_space after
