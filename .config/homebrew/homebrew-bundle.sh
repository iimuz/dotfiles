#!/usr/bin/env bash
#
# homebrew bundleのための設定ファイル。
# - [homebrew bundle](https://github.com/Homebrew/homebrew-bundle)

# === homebrewのパスが既にある場合は削除
# guardより前で実施しないと環境を切り替えた方に入っていないとパスが削除できない
# HOMEBREW_PREFIXが定義されていない場合は、事前に定義がないのでパスは設定されていない
# if [ -n "$HOMEBREW_PREFIX" ]; then
#   # homebrewのインストール先が `/usr/local/bin` の場合は、参照を消すと他も消えるので消せない
#   if [ "$HOMEBREW_PREFIX/bin" != "/usr/local/bin" ]; then
#     remove_path "$HOMEBREW_PREFIX/bin"
#   fi
#   remove_path "$HOMEBREW_PREFIX/sbin"
# fi

# === Gurad if command does not exist.
# binを削除しておくとbrew commandの有無で判別できない。
# 一度でも設定して環境変数を全て削除していない想定で環境変数の有無でhomebrewの有無を確認する。
# if ! type brew > /dev/null 2>&1; then return 0; fi
# if [ ! -n "$HOMEBREW_PREFIX" ]; then return 0; fi

# === mac環境においてarm版とrosetta版を実行環境で切り替える
# ref: <https://qiita.com/tamachan210/items/b253ced93425d7cc0f1f>
if [ "$(uname)" = "Darwin" ]; then  # MacOS
  if [ "$(uname -m)" = "arm64" ]; then  # Apple silicon
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else  # Intel
    eval "$(/usr/local/bin/brew shellenv)"
  fi
elif [ "$(uname)" = "Linux" ]; then  # Linux
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# === current directory
if [[ "$SHELL" == *bash ]]; then
  current_directory="$(cd $(dirname $BASH_SOURCE); pwd)"
elif [[ "$SHELL" == *zsh ]]; then
  current_directory="$(cd $(dirname ${(%):-%N}); pwd)"
fi

# === Brewfileの場所を設定
if [ "$(uname)" = "Darwin" ]; then  # MacOS
  if [ "$(uname -m)" = "arm64" ]; then  # Apple silicon
    export HOMEBREW_BUNDLE_FILE="$current_directory/Brewfile-mac"
  else  # Intel
    export HOMEBREW_BUNDLE_FILE="$current_directory/Brewfile-rosetta"
  fi
elif [ "$(uname)" = "Linux" ]; then  # Linux
  if [[ "$(uname -r)" == *microsoft* ]]; then  # WSL
    export HOMEBREW_BUNDLE_FILE="$current_directory/Brewfile-wsl"
  elif  [[ "$(uname -r)" == *aws ]]; then
    export HOMEBREW_BUNDLE_FILE="$current_directory/Brewfile-ec2"
  fi
fi
