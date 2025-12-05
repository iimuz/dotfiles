#!/bin/bash

# 非インタラクティブシェルでも環境変数を設定
source ~/.selfrc

exec "$@"
