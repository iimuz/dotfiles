---
status: DONE
---

# TASK: Fix npm.sh startup noise and npm unavailability

## GOAL

- Goal: `.config/node/npm.sh` のシェル起動時に出力される冗長な `script_path=...` を抑止し、修正に伴う `npm: command not found` を解消する。

## REF

- `.config/node/npm.sh`
- `.config/node/npmrc`
- `.config/node/nvm-settings.sh`

## STEPS

- [x] Step 1: `_change_default_npm_directory` 内の冗長な `local script_path` 再宣言（旧38行目）を削除する。
- [x] Step 2: `export PATH=$(npm config get prefix)/bin:$PATH` を `export PATH=${NPM_USER_PREFIX}/bin:$PATH` に置き換える。

## VERIFY

- Verify: 新しいシェルを起動したとき `script_path=...` が出力されない、かつ `command -v npm` が正常にパスを返す。

## SCRATCHPAD

- 根本原因 (issue 1): zsh では `local varname`（値なし）を既にローカル宣言済みの変数に再適用すると、現在値を
  `varname=value` の形式で出力したうえで空にリセットする。旧38行目の `local script_path` がこれに該当し、
  起動時に毎回 `script_path=/path/to/npm.sh` を表示していた。
- 根本原因 (issue 2): 旧コードでは `local script_path` のリセットにより `script_path` が空になり、
  `$(cd .; pwd)` = `$PWD` が代入されていた。結果、`NPM_CONFIG_USERCONFIG` は存在しないパス（`$PWD/npmrc`）を指し、
  npm はデフォルト設定にフォールバックして nvm の prefix（npm バイナリを含む）を返していた。修正後は正しい npmrc が
  読み込まれ `npm config get prefix` が `$NPM_USER_PREFIX` を返すが、この bin には npm バイナリが存在しないため
  `npm: command not found` になる。
- 修正方針: `local script_path` 再宣言を削除し、PATH 構築で `$(npm config get prefix)` の代わりに既設の `$NPM_USER_PREFIX` を直接使用することで循環依存を排除。
- 副作用: `$(npm config get prefix)` のサブプロセス呼び出し（約100〜300ms）がなくなり起動が高速化。
- 既存の未修正問題（スコープ外）: `cd $(dirname "$script_path")` のクォート不足、`cd` 失敗時のエラーハンドリング欠如。
