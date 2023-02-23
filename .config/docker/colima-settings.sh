#!/usr/bin/env bash
#
# colima利用時の環境設定

# mac環境でcolimaが含まれている場合の追加設定
if ! type colima > /dev/null 2>&1; then return 0; fi

# virtualization frameworkで起動する
# `--mount_type virtiofs` は `--vm-type vz` の場合はデフォルトだが念の為設定
alias colima_vz='colima start --vm-type vz --mount-type virtiofs'
# aarch64アーキテクチャでrosettaを利用した環境を構築する
# vzが利用できて `--vz-rosetta` が利用できない場合は、オプションが用意されていない可能性がある。
# オプションが用意されていない場合は、デフォルトで有効らしい。
# ref: <https://github.com/abiosoft/colima/issues/554>
# alias colima_rosetta='colima start --arch aarch64 --vm-type=vz --vz-rosetta'
alias colima_rosetta='colima start --arch=aarch64 --vm-type=vz'


