#!/usr/bin/env bash
#
# colima利用時の環境設定

# mac環境でcolimaが含まれている場合の追加設定
if ! type colima > /dev/null 2>&1; then return 0; fi

alias colima_vz='colima start --vm-type vz --mount-type virtiofs'

