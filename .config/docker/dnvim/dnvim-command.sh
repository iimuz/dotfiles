#!/usr/bin/env bash
#
# docker 環境での neovim 呼出コマンドの定義

if ! type docker >/dev/null 2>&1; then return 0; fi

dcopilot() {
  local -r DENY_TOOLS=(
    --deny-tool='shell(git checkout:*)'
    --deny-tool='shell(git push:*)'
    --deny-tool='shell(git rebase:*)'
    --deny-tool='shell(git reset:*)'
    --deny-tool='shell(git switch:*)'
    --deny-tool='shell(npm remove:*)'
    --deny-tool='shell(npm uninstall:*)'
    --deny-tool='shell(rm -f:*)'
    --deny-tool='shell(rm -rf:*)'
    --deny-tool='shell(sudo:*)'
  )

  dnvim exec copilot "${DENY_TOOLS[@]}" "$@"
}

dlazygit() {
  dnvim exec lazygit "$@"
}

dgh() {
  dnvim exec gh "$@"
}

dgit() {
  dnvim exec git "$@"
}

dnvim() {
  local -r LOCAL_DOTFILES_CONFIG_DIR=$(realpath "$_DOTFILES_CONFIG_DIR/..")
  local -r COMPOSE_FILE="$_DOTFILES_CONFIG_DIR/docker/dnvim/docker-compose.yml"
  local -r PROJECT_NAME="dnvim"
  local -r GITHUB_TOKEN=$(gh auth token 2>/dev/null || echo "")
  local LOCAL_USER_UID=1000
  local LOCAL_USER_GID=1000
  if [[ "$(uname -s)" == "Linux" ]]; then
    LOCAL_USER_UID=$(id -u)
    LOCAL_USER_GID=$(id -g)
  fi
  readonly LOCAL_USER_UID
  readonly LOCAL_USER_GID

  # docker composeのベースコマンド
  local -a env_vars=(
    "DOTFILES_CONFIG_DIR=$LOCAL_DOTFILES_CONFIG_DIR"
    "USER_UID=$LOCAL_USER_UID"
    "USER_GID=$LOCAL_USER_GID"
  )
  if [[ "$(uname -s)" == "Linux" ]]; then
    env_vars+=(
      "USER_UID=$(id -u)"
      "USER_GID=$(id -g)"
    )
  fi

  local -ar BASE_CMD=(
    env "${env_vars[@]}"
    docker compose
    -f "$COMPOSE_FILE"
    --project-name "$PROJECT_NAME"
    --project-directory .
  )

  case "${1:-}" in
  build)
    (cd "$_DOTFILES_CONFIG_DIR/docker/dnvim" &&
      env "${env_vars[@]}" docker compose -f "$COMPOSE_FILE" build)
    ;;
  rebuild)
    (cd "$_DOTFILES_CONFIG_DIR/docker/dnvim" &&
      env "${env_vars[@]}" docker compose -f "$COMPOSE_FILE" build --no-cache)
    ;;
  logs)
    "${BASE_CMD[@]}" logs -f
    ;;
  exec)
    shift
    "${BASE_CMD[@]}" run -e GITHUB_TOKEN="$GITHUB_TOKEN" --rm -it dev "$@"
    ;;
  shell)
    "${BASE_CMD[@]}" run -e GITHUB_TOKEN="$GITHUB_TOKEN" --rm -it dev zsh
    ;;
  --help | -h | help)
    cat <<EOF
Usage: dnvim [COMMAND] [OPTIONS]

Commands:
  (none)           Start Neovim
  <file>           Open file(s) in Neovim
  build            Build Docker image
  rebuild          Rebuild without cache
  logs             Show container logs
  exec <cmd>       Execute command in container
  shell            Open shell in container
  help             Show this help

Examples:
  dnvim                    # Start Neovim
  dnvim file.txt           # Open file.txt
  dnvim build              # Build image
  dnvim exec ls -la        # Run ls command
EOF
    ;;

  *)
    "${BASE_CMD[@]}" run -e GITHUB_TOKEN="$GITHUB_TOKEN" --rm -it dev nvim "$@"
    ;;
  esac
}
