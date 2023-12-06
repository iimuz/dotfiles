#!/usr/bin/env bash
#
# xcode利用時の環境設定

# mac環境でxcodeが含まれている場合の追加設定
if ! type xcodebuild > /dev/null 2>&1; then return 0; fi

if [ -n "/Applications/Xcode.app/Contents/Developer/usr/bin" ]; then
  export PATH="$PATH:/Applications/Xcode.app/Contents/Developer/usr/bin"
fi

