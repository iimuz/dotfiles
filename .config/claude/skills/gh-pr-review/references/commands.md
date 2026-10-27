# gh のコマンド例

PR の確認で集める情報と、そのコマンドを示す。
`<PR>` は PR 番号、`<owner>/<repo>` は PR のあるリポジトリである。

## PR の状態

```bash
gh pr view <PR> --json number,title,body,url,author,state,isDraft,mergeable,mergeStateStatus,reviewDecision,closingIssuesReferences,baseRefName,headRefOid,headRepository,headRepositoryOwner,isCrossRepository,files
```

- `statusCheckRollup` には古い実行が混ざるので使わず、CI は後の `gh pr checks` で見る
- `mergeable` が `UNKNOWN` は、GitHub が計算していない状態である
- `reviewDecision` が空は、必須の承認が無いリポジトリである

## 差分

```bash
gh pr diff <PR>
```

説明を書くために、会話に残す。

## CI の最新の結果

```bash
gh pr checks <PR> --json name,state,bucket,workflow,link
```

- `bucket` は `pass`、`fail`、`pending`、`skipping`、`cancel` のどれかである
- 標準出力が JSON の配列なら、終了コードに関わらず `bucket` から CI の結果を読む
- check が 1 つも無いと、JSON を出さずに `no checks reported` を出して 0 以外で終わる。
  これは gh の失敗ではなく、Merge の条件に CI「無し」と書く
- それ以外で JSON が返らないときは gh のエラーとして扱う

## Issue

```bash
gh issue view <N> -R <owner>/<repo> --json number,title,body,state,comments
```

`<owner>/<repo>` は `closingIssuesReferences[].repository` から取る。

## レビュースレッド、レビュー本文、会話欄のコメント

```bash
gh api graphql -f owner=<owner> -f repo=<repo> -F number=<PR> -f query='
query($owner: String!, $repo: String!, $number: Int!) {
  repository(owner: $owner, name: $repo) {
    pullRequest(number: $number) {
      reviewThreads(first: 100) {
        pageInfo { hasNextPage }
        nodes {
          isResolved
          isOutdated
          path
          line
          originalLine
          comments(first: 50) {
            pageInfo { hasNextPage }
            nodes { author { __typename login } body createdAt }
          }
        }
      }
      reviews(first: 100) {
        pageInfo { hasNextPage }
        nodes { author { __typename login } state body submittedAt }
      }
      comments(first: 100) {
        pageInfo { hasNextPage }
        nodes { author { __typename login } body createdAt }
      }
    }
  }
}'
```

- owner と repo は `-f` で文字列として渡す。
  `-F` は数字や `true` に見える値の型を変えるので、number だけに使う
- どれかの `pageInfo.hasNextPage` が `true` なら、続きを読んでいないことを報告のスレッドの節に書く
- outdated のスレッドは `line` が null になるので、場所は `originalLine` で示す。
  outdated は指摘の行が後の commit で変わった手がかりであり、指摘に応えたかは変更を読んで決める

## bot の判定

`author.__typename` が `Bot` のものを bot とする。
GraphQL の bot の login には `[bot]` が付かないので、login の末尾では見分けない。

## PR の head のファイル

```bash
gh api "repos/<owner>/<repo>/contents/<path>?ref=<headRefOid>" -H "Accept: application/vnd.github.raw"
```

`isCrossRepository` が `true` のときは、`<owner>/<repo>` に `headRepositoryOwner.login` と `headRepository.name` を使う。
Issue のリンクが指す同じリポジトリのファイルも、同じ API でリンクの URL にある ref を指定して読む。
