---
name: js-page-fetch
description: >-
  JavaScript の描画が要るページの取り方を決める。WebFetch や ctx_fetch_and_index が空のシェルや
  内容の無い骨組みだけを返したとき、またはサイトが headless の user agent を 403 で弾いたときに使う。
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

macOS では `--browser chrome --headed` を使う。`--headed` を付けないと UA に `HeadlessChrome` が残り、
headless を弾くサイトで 403 になる。

Linux には Chrome がなく、ディスプレイもないため `--headed` は使えない。
`--browser` を指定せず chromium をヘッドレスで使うが、headless を弾くサイトは
同じ理由で 403 になりうる。回避策は未検証。そのようなサイトに当たったら
`--config` でのカスタム UA 上書きなど別の手段を調査する。

### プロファイル

`--persistent`、`--profile`、`attach --cdp=chrome` は使わない。既定の一時プロファイル
だけを使い、ユーザーの Chrome プロファイルには触れない。ログインが必要なページは
このスキルの対象外とする。

### 取り出し方

DOM を掻き集める前に `requests` と `response-body` でページが叩いている JSON
エンドポイントを探す。表形式のデータは、レンダリング結果より元の JSON のほうが
速く確実に取れる。

出力が大きいときは設定ファイルで `outputMode` を `file` にしてファイルに落とす。

locale で表示が変わる SPA は `browser.contextOptions.locale` を指定する。
`accept-language` ヘッダだけでは切り替わらないことがある。

本文抽出ツールは記事本文だけを残すため、料金表のような UI コンポーネントを落とす。ページ全体の構造や
レイアウトが要るときは本文抽出を使わず、`snapshot` でページ構造を、`requests` でエンドポイントを取る。
