#!/usr/bin/env bash
#
# docker 環境での GitHub Copilot コマンドの定義

if ! type docker >/dev/null 2>&1; then return 0; fi

dcopilot() {
  local -r LOCAL_DOTFILES_CONFIG_DIR=$(realpath "$_DOTFILES_CONFIG_DIR/..")
  local -r COMPOSE_FILE="$_DOTFILES_CONFIG_DIR/docker/dcopilot/docker-compose.yml"
  local -r PROJECT_NAME="dcopilot"
  local -r GITHUB_TOKEN=$(gh auth token 2>/dev/null || echo "")

  # docker composeのベースコマンド
  local -a ENV_VARS=(
    "DOTFILES_CONFIG_DIR=$LOCAL_DOTFILES_CONFIG_DIR"
  )
  if [[ "$(uname -s)" == "Linux" ]]; then
    env_vars+=(
      "USER_UID=$(id -u)"
      "USER_GID=$(id -g)"
    )
  fi
  readonly ENV_VARS

  local -r BASE_CMD=(
    env "${ENV_VARS[@]}"
    docker compose
    -f "$COMPOSE_FILE"
    --project-name "$PROJECT_NAME"
    --project-directory .
  )

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

  case "${1:-}" in
  build)
    (cd "$_DOTFILES_CONFIG_DIR/docker/dcopilot" &&
      "${BASE_CMD[@]}" build)
    ;;
  rebuild)
    (cd "$_DOTFILES_CONFIG_DIR/docker/dcopilot" &&
      "${BASE_CMD[@]}" build --no-cache)
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
Usage: dcopilot [COMMAND] [OPTIONS]

Commands:
  (none)           Start copilot
  (cmd)            Start copilot with command
  build            Build Docker image
  rebuild          Rebuild without cache
  clogs            Show container logs
  exec <cmd>       Execute command in container
  shell            Open shell in container
  help             Show this help

Examples:
  dcopilot             # Start Copilot
  dcopilot build       # Build image
EOF
    ;;
  *)
    "${BASE_CMD[@]}" run -e GITHUB_TOKEN="$GITHUB_TOKEN" --rm -it dev copilot "${DENY_TOOLS[@]}" "$@"
    ;;
  esac
}
