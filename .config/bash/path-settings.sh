#!/usr/bin/env bash
#
# PATHを操作するための便利関数を定義する。

# 第一引数に渡したパス文字列をPATHから削除する。
function remove_path () {
  export PATH=`echo -n $PATH | awk -v RS=: -v ORS=: '$0 != "'$1'"' | sed 's/:$//'`;
}

