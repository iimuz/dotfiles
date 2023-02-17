#!/usr/bin/env bash
#
# homebrew bundleのための設定ファイル。
# - [homebrew bundle](https://github.com/Homebrew/homebrew-bundle)

# Gurad if command does not exist.
if ! type brew > /dev/null 2>&1; then return 0; fi

# === homebrewのパスが既にある場合は削除
# HOMEBREW_PREFIXが定義されていない場合は、事前に定義がないのでパスは設定されていない
if [ -n "$HOMEBREW_PREFIX" ]; then
  # homebrewのインストール先が `/usr/local/bin` の場合は、参照を消すと他も消えるので消せない
  if [ "$HOMEBREW_PREFIX/bin" != "/usr/local/bin" ]; then
    remove_path "$HOMEBREW_PREFIX/bin"
  fi
  remove_path "$HOMEBREW_PREFIX/sbin"
fi

# === mac環境においてarm版とrosetta版を実行環境で切り替える
# ref: <https://qiita.com/tamachan210/items/b253ced93425d7cc0f1f>
if [ "$(uname)" = "Darwin" ]; then  # MacOS
  if [ "$(uname -m)" = "arm64" ]; then  # Apple silicon
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else  # Intel
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

# === Brewfileの場所を設定
if [ "$(uname)" = "Darwin" ]; then  # MacOS
  if [ "$(uname -m)" = "arm64" ]; then  # Apple silicon
    export HOMEBREW_BUNDLE_FILE="$(cd $(dirname ${(%):-%N}); pwd)/Brewfile-mac"
  else  # Intel
    export HOMEBREW_BUNDLE_FILE="$(cd $(dirname ${(%):-%N}); pwd)/Brewfile-rosetta"
  fi
elif [ "$(uname)" = "Linux" ]; then  # Linux
  if [[ "$(uname -r)" == *microsoft* ]]; then  # WSL
    export HOMEBREW_BUNDLE_FILE="$(cd $(dirname ${(%):-%N}); pwd)/Brewfile-wsl"
  fi
fi

