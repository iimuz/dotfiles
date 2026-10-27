# gh のコマンド例

PR の確認で集める情報と、そのコマンドを示す。
`<PR>` は PR 番号、`<owner>/<repo>` は PR のあるリポジトリである。

## PR の状態

```bash
gh pr view <PR> --json number,title,body,url,author,state,isDraft,mergeable,mergeStateStatus,reviewDecision,closingIssuesReferences,baseRefName,headRefOid,headRepository,headRepositoryOwner,isCrossRepository,files,comments,reviews
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
- 終了コードは、失敗があると 1、実行中があると 8 になる。check が 1 つも無いと `no checks reported` を出して 1 で終わる。
  これらは gh の失敗ではなく CI の結果として扱い、Merge の条件に「失敗」「実行中」「無し」と書く
- 標準出力が JSON の配列なら、終了コードが 0 以外でも結果として読む。認証の失敗 (終了コード 4) と、JSON が返らない失敗は gh のエラーとして扱う

## Issue

```bash
gh issue view <N> -R <owner>/<repo> --json number,title,body,state,comments
```

`<owner>/<repo>` は `closingIssuesReferences[].repository` から取る。

## レビュースレッド

```bash
gh api graphql -F owner=<owner> -F repo=<repo> -F number=<PR> -f query='
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
          comments(first: 50) {
            nodes { author { __typename login } body createdAt }
          }
        }
      }
    }
  }
}'
```

`pageInfo.hasNextPage` が `true` なら、101 件目以降を読んでいないことを報告のスレッドの節に書く。

## bot の判定

- スレッドでは `author.__typename` が `Bot` のもの
- `gh pr view` の `comments` と `reviews` では、login が `[bot]` で終わるもの

## PR の head のファイル

```bash
gh api "repos/<owner>/<repo>/contents/<path>?ref=<headRefOid>" -H "Accept: application/vnd.github.raw"
```

`isCrossRepository` が `true` のときは、`<owner>/<repo>` に `headRepositoryOwner.login` と `headRepository.name` を使う。
Issue のリンクが指す同じリポジトリのファイルも、同じ API でリンクの URL にある ref を指定して読む。
