#!/bin/bash
#
# Copilot cli settings.

# Guard if command does not exist.
if ! type copilot >/dev/null 2>&1; then return 0; fi

function copilot_auto() {
  local -ar env_vars=(
    "EDITOR=${EDITOR:-nvim}"
  )
  local -ar OPTIONS=(
    "--deny-tool=shell(git checkout:*)"
    "--deny-tool=shell(git push:*)"
    "--deny-tool=shell(git rebase:*)"
    "--deny-tool=shell(git reset:*)"
    "--deny-tool=shell(git switch:*)"
    "--deny-tool=shell(npm remove:*)"
    "--deny-tool=shell(npm uninstall:*)"
    "--deny-tool=shell(rm -f:*)"
    "--deny-tool=shell(rm -rf:*)"
    "--deny-tool=shell(sudo:*)"
    "--allow-all-tools"
    # tmp 利用は許可
    "--add-dir=/tmp"
    # mac の場合 tmp が `/private/tmp` へのリンクのため許可
    "--add-dir=/private/tmp"
    # source code 関連は相互参照を許可
    "--add-dir=$HOME/src"
    # 共通 skills のアクセスチェックが入るため
    "--add-dir=$HOME/.copilot/skills"
    # session フォルダへの書き出しと相互参照を許可
    "--add-dir=$HOME/.copilot/session-state"
  )
  env "${env_vars[@]}" copilot "${OPTIONS[@]}" "$@"
}

function copilot_custom() {
  local -ar env_vars=(
    "EDITOR=${EDITOR:-nvim}"
  )
  local -ar OPTIONS=(
    "--deny-tool=shell(git push:*)"
    "--deny-tool=shell(rm -f:*)"
    "--deny-tool=shell(rm -rf:*)"
    "--deny-tool=shell(sudo:*)"
    # tmp 利用は許可
    "--add-dir=/tmp"
    # mac の場合 tmp が `/private/tmp` へのリンクのため許可
    "--add-dir=/private/tmp"
    # source code 関連は相互参照を許可
    "--add-dir=$HOME/src"
    # 共通 skills のアクセスチェックが入るため
    "--add-dir=$HOME/.copilot/skills"
    # session フォルダへの書き出しと相互参照を許可
    "--add-dir=$HOME/.copilot/session-state"
  )
  env "${env_vars[@]}" copilot "${OPTIONS[@]}" "$@"
}

function copilot_yolo() {
  local -ar env_vars=(
    "EDITOR=${EDITOR:-nvim}"
  )
  local -ar OPTIONS=(
    "--deny-tool=shell(git push:*)"
    "--deny-tool=shell(rm -f:*)"
    "--deny-tool=shell(rm -rf:*)"
    "--deny-tool=shell(sudo:*)"
    "--allow-url=github.com"
    "--allow-url=aws.amazon.com"
    "--allow-all-tools"
    "--allow-all-paths"
  )
  env "${env_vars[@]}" copilot "${OPTIONS[@]}" "$@"
}

function copilot_prompt() {
  if ! type rg >/dev/null 2>&1; then
    echo "rg command is required" >&2
    return 1
  fi

  local -r usage="usage: copilot_prompt [--yolo|--auto] [-i|-p] [--model <model>] [--agent <agent>] <markdown-file> [-- <extra-args...>]"
  local strategy="auto"
  local strategy_specified=""
  local launch_mode="interactive"
  local model="claude-sonnet-4.6"
  local agent="default"
  local source_file=""
  local mode_specified=""
  local -a extra_args=()

  while [ "$#" -gt 0 ]; do
    case "$1" in
      --yolo)
        if [ "$strategy_specified" = "true" ] && [ "$strategy" != "yolo" ]; then
          echo "--yolo and --auto cannot be combined" >&2
          return 1
        fi
        strategy="yolo"
        strategy_specified="true"
        shift
        ;;
      --auto)
        if [ "$strategy_specified" = "true" ] && [ "$strategy" != "auto" ]; then
          echo "--yolo and --auto cannot be combined" >&2
          return 1
        fi
        strategy="auto"
        strategy_specified="true"
        shift
        ;;
      -i)
        if [ "$mode_specified" = "true" ] && [ "$launch_mode" != "interactive" ]; then
          echo "-i and -p cannot be combined" >&2
          return 1
        fi
        launch_mode="interactive"
        mode_specified="true"
        shift
        ;;
      -p)
        if [ "$mode_specified" = "true" ] && [ "$launch_mode" != "prompt" ]; then
          echo "-i and -p cannot be combined" >&2
          return 1
        fi
        launch_mode="prompt"
        mode_specified="true"
        shift
        ;;
      --model)
        if [ "$#" -lt 2 ] || [ -z "$2" ] || [[ "$2" == -* ]]; then
          echo "--model requires a value" >&2
          return 1
        fi
        model="$2"
        shift 2
        ;;
      --agent)
        if [ "$#" -lt 2 ] || [ -z "$2" ] || [[ "$2" == -* ]]; then
          echo "--agent requires a value" >&2
          return 1
        fi
        agent="$2"
        shift 2
        ;;
      --)
        shift
        while [ "$#" -gt 0 ]; do
          if [ -z "$source_file" ]; then
            source_file="$1"
          else
            extra_args+=("$1")
          fi
          shift
        done
        break
        ;;
      -*)
        if [ -z "$source_file" ]; then
          echo "unexpected option or leading-dash filename without --: $1" >&2
          echo "$usage" >&2
          return 1
        fi
        extra_args+=("$1")
        shift
        ;;
      *)
        if [ -z "$source_file" ]; then
          source_file="$1"
        else
          extra_args+=("$1")
        fi
        shift
        ;;
    esac
  done

  if [ -z "$source_file" ]; then
    echo "$usage" >&2
    return 1
  fi
  if [ ! -f "$source_file" ]; then
    echo "file not found: $source_file" >&2
    return 1
  fi

  local prompt_section
  prompt_section="$(rg -U --pcre2 '(?s)^## Prompt\n(.*?)(?=^## |\z)' -- "$source_file" | tail -n +2)" || true
  if [ -z "$prompt_section" ]; then
    echo "## Prompt section is empty or missing: $source_file" >&2
    return 1
  fi

  local -r prompt_text="$(
    cat <<EOF
${prompt_section}

Update ${source_file}.
EOF
  )"

  local -a mode_opts=()
  if [ "$launch_mode" = "interactive" ]; then
    mode_opts+=("--interactive" "$prompt_text")
  else
    mode_opts+=("--prompt" "$prompt_text")
    mode_opts+=("--autopilot")
    mode_opts+=("--no-ask-user")
  fi

  local -ar model_opts=("--model" "$model")
  local -a agent_opts=()
  if [ "$agent" != "default" ]; then
    agent_opts+=("--agent")
    agent_opts+=("$agent")
  fi

  case "$strategy" in
    yolo)
      if ! type copilot_yolo >/dev/null 2>&1; then
        echo "copilot_yolo function is required" >&2
        return 1
      fi
      copilot_yolo \
        ${mode_opts[@]+"${mode_opts[@]}"} \
        ${model_opts[@]+"${model_opts[@]}"} \
        ${agent_opts[@]+"${agent_opts[@]}"} \
        ${extra_args[@]+"${extra_args[@]}"}
      ;;
    *)
      if ! type copilot_auto >/dev/null 2>&1; then
        echo "copilot_auto function is required" >&2
        return 1
      fi
      copilot_auto \
        ${mode_opts[@]+"${mode_opts[@]}"} \
        ${model_opts[@]+"${model_opts[@]}"} \
        ${agent_opts[@]+"${agent_opts[@]}"} \
        ${extra_args[@]+"${extra_args[@]}"}
      ;;
  esac
}
