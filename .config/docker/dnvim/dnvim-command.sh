#!/usr/bin/env bash
#
# docker 環境での neovim 呼出コマンドの定義

if ! type docker >/dev/null 2>&1; then return 0; fi

dnvim() {
  local -r LOCAL_DOTFILES_CONFIG_DIR=$(realpath "$_DOTFILES_CONFIG_DIR/..")
  local -r COMPOSE_FILE="$_DOTFILES_CONFIG_DIR/docker/dnvim/docker-compose.yml"
  local -r PROJECT_NAME="dnvim"
  local -r GITHUB_TOKEN=$(gh auth token 2>/dev/null || echo "")
  local USER_UID=1000
  local USER_GID=1000
  if [[ "$(uname -s)" == "Linux" ]]; then
    USER_UID=$(id -u)
    USER_GID=$(id -g)
  fi

  # docker composeのベースコマンド
  local -r BASE_CMD=(
    DOTFILES_CONFIG_DIR="$LOCAL_DOTFILES_CONFIG_DIR"
    USER_UID="$USER_UID"
    USER_GID="$USER_GID"
    docker compose
    -f "$COMPOSE_FILE"
    --project-name "$PROJECT_NAME"
    --project-directory .
  )

  case "${1:-}" in
  build)
    (cd "$_DOTFILES_CONFIG_DIR/docker/dnvim" &&
      DOTFILES_CONFIG_DIR="$LOCAL_DOTFILES_CONFIG_DIR" \
        USER_UID="$USER_UID" USER_GID="$USER_GID" \
        docker compose -f "$COMPOSE_FILE" build)
    ;;
  rebuild)
    (cd "$_DOTFILES_CONFIG_DIR/docker/dnvim" &&
      DOTFILES_CONFIG_DIR="$LOCAL_DOTFILES_CONFIG_DIR" \
        USER_UID="$USER_UID" USER_GID="$USER_GID" \
        docker compose -f "$COMPOSE_FILE" build --no-cache)
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
