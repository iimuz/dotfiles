#!/usr/bin/env bash
#
# docker 環境での git 関連の呼出コマンドの定義
# 呼び出している image は同じなので git 以外のコマンドは最小限の定義のみ用意する

if ! type docker >/dev/null 2>&1; then return 0; fi

dgh() {
  local -r LOCAL_DOTFILES_CONFIG_DIR=$(realpath "$_DOTFILES_CONFIG_DIR/..")
  local -r COMPOSE_FILE="$_DOTFILES_CONFIG_DIR/docker/dgit/docker-compose.yml"
  local -r PROJECT_NAME="dgit"
  local -r GITHUB_TOKEN=$(gh auth token 2>/dev/null || echo "")

  # docker composeのベースコマンド
  local -r BASE_CMD=(
    docker compose
    -f "$COMPOSE_FILE"
    --project-name "$PROJECT_NAME"
    --project-directory .
  )

  case "${1:-}" in
  --help | -h | help)
    cat <<EOF
Usage: dgh [COMMAND] [OPTIONS]

Commands:
  (none) Start gh command
  help   Show this help

Examples:
  dgh # Start gh command
EOF
    ;;
  *)
    DOTFILES_CONFIG_DIR="$LOCAL_DOTFILES_CONFIG_DIR" \
      "${BASE_CMD[@]}" run -e GITHUB_TOKEN="$GITHUB_TOKEN" --rm -it dev gh "$@"
    ;;
  esac
}

dgit() {
  local -r LOCAL_DOTFILES_CONFIG_DIR=$(realpath "$_DOTFILES_CONFIG_DIR/..")
  local -r COMPOSE_FILE="$_DOTFILES_CONFIG_DIR/docker/dgit/docker-compose.yml"
  local -r PROJECT_NAME="dgit"
  local -r GITHUB_TOKEN=$(gh auth token 2>/dev/null || echo "")

  # docker composeのベースコマンド
  local -r BASE_CMD=(
    docker compose
    -f "$COMPOSE_FILE"
    --project-name "$PROJECT_NAME"
    --project-directory .
  )

  case "${1:-}" in
  build)
    (cd "$_DOTFILES_CONFIG_DIR/docker/dgit" &&
      DOTFILES_CONFIG_DIR="$LOCAL_DOTFILES_CONFIG_DIR" \
        docker compose -f "$COMPOSE_FILE" build)
    ;;
  rebuild)
    (cd "$_DOTFILES_CONFIG_DIR/docker/dgit" &&
      DOTFILES_CONFIG_DIR="$LOCAL_DOTFILES_CONFIG_DIR" \
        docker compose -f "$COMPOSE_FILE" build --no-cache)
    ;;
  clogs)
    DOTFILES_CONFIG_DIR="$LOCAL_DOTFILES_CONFIG_DIR" \
      "${BASE_CMD[@]}" logs -f
    ;;
  exec)
    shift
    DOTFILES_CONFIG_DIR="$LOCAL_DOTFILES_CONFIG_DIR" \
      "${BASE_CMD[@]}" run -e GITHUB_TOKEN="$GITHUB_TOKEN" --rm -it dev "$@"
    ;;
  shell)
    DOTFILES_CONFIG_DIR="$LOCAL_DOTFILES_CONFIG_DIR" \
      "${BASE_CMD[@]}" run -e GITHUB_TOKEN="$GITHUB_TOKEN" --rm -it dev bash
    ;;
  --help | -h | help)
    cat <<EOF
Usage: dgit [COMMAND] [OPTIONS]

Commands:
  (none)           Start git
  (cmd)            Start git with command
  build            Build Docker image
  rebuild          Rebuild without cache
  clogs            Show container logs
  exec <cmd>       Execute command in container
  shell            Open shell in container
  help             Show this help

Examples:
  dgit                  # Start Neovim
  dgit status           # Show git status
  dgit build            # Build image
  dgit exec ls -la      # Run ls command
EOF
    ;;

  *)
    DOTFILES_CONFIG_DIR="$LOCAL_DOTFILES_CONFIG_DIR" \
      "${BASE_CMD[@]}" run -e GITHUB_TOKEN="$GITHUB_TOKEN" --rm -it dev git "$@"
    ;;
  esac
}

dlazygit() {
  local -r LOCAL_DOTFILES_CONFIG_DIR=$(realpath "$_DOTFILES_CONFIG_DIR/..")
  local -r COMPOSE_FILE="$_DOTFILES_CONFIG_DIR/docker/dgit/docker-compose.yml"
  local -r PROJECT_NAME="dgit"
  local -r GITHUB_TOKEN=$(gh auth token 2>/dev/null || echo "")

  # docker composeのベースコマンド
  local -r BASE_CMD=(
    docker compose
    -f "$COMPOSE_FILE"
    --project-name "$PROJECT_NAME"
    --project-directory .
  )

  case "${1:-}" in
  --help | -h | help)
    cat <<EOF
Usage: dlazygit [COMMAND] [OPTIONS]

Commands:
  (none) Start lazygit command
  help   Show this help

Examples:
  dlazygit # Start lazygit command
EOF
    ;;
  *)
    DOTFILES_CONFIG_DIR="$LOCAL_DOTFILES_CONFIG_DIR" \
      "${BASE_CMD[@]}" run -e GITHUB_TOKEN="$GITHUB_TOKEN" --rm -it dev lazygit "$@"
    ;;
  esac
}
