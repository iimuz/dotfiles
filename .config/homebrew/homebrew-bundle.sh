# homebrew bundleのための設定ファイル。
# - [homebrew bundle](https://github.com/Homebrew/homebrew-bundle)

# Brewfileの場所を設定
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
