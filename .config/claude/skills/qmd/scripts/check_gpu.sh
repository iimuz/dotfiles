#!/usr/bin/env bash
# qmd 2.5.x は `qmd status` に GPU 行を出力しないため、
# `qmd doctor` の device probe 行だけが GPU 判定の信頼できる手掛かりになる。
set -u

if qmd doctor 2>/dev/null | grep 'device probe' | grep -Eq 'GPU (metal|vulkan|cuda)'; then
  echo "gpu"
else
  echo "cpu"
fi
