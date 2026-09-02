---
name: js-page-fetch
description: >-
  Decide how to fetch a page whose content needs JavaScript rendering. Use when
  WebFetch or ctx_fetch_and_index returns an empty shell or a skeleton without
  the content, or when a site rejects a headless user agent with 403.
---

# JS 描画ページの取得

素の HTTP fetch で内容が取れないページは `playwright-cli` で取得する。
コマンドの使い方は同梱スキル `playwright-cli` にある。ここには、そのスキルが答えない
この環境固有の判断だけを書く。

## いつ使うか

- `WebFetch` や `ctx_fetch_and_index` が空のシェルや骨組みだけを返した。
- 目的の内容がアコーディオンやタブの内側にあり、初期 DOM に存在しない。
- サイトが headless の user agent を 403 で弾いた。

同梱スキルは browser automation とテスト作成を前提に書かれているため、この用途では
起動しない。上記に当てはまるときは「情報が公開されていない」と結論づける前に試す。

## この環境での決めごと

### ブラウザ

macOS では `--browser chrome` を付けて Homebrew の Google Chrome を使う。
headless の user agent を弾くサイトを回避できる。Linux には Chrome がないので
`--browser` を指定せず chromium を使う。

### プロファイル

`--persistent`、`--profile`、`attach --cdp=chrome` は使わない。既定の一時プロファイル
だけを使い、ユーザーの Chrome プロファイルには触れない。ログインが必要なページは
このスキルの対象外とする。

### 取り出し方

DOM を掻き集める前に `requests` と `response-body` でページが叩いている JSON
エンドポイントを探す。表形式のデータは、レンダリング結果より元の JSON のほうが
速く確実に取れる。

出力が大きいときは設定ファイルで `outputMode` を `file` にしてファイルに落とし、
context-mode の `ctx_execute_file` で解析する。生データをコンテキストに載せない。

locale で表示が変わる SPA は `browser.contextOptions.locale` を指定する。
`accept-language` ヘッダだけでは切り替わらないことがある。
