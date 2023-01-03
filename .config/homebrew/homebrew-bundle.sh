# homebrew bundleのための設定ファイル。
# - [homebrew bundle](https://github.com/Homebrew/homebrew-bundle)

# Brewfileの場所を設定
export HOMEBREW_BUNDLE_FILE="$(cd $(dirname ${BASH_SOURCE:-0}); pwd)/Brewfile"
