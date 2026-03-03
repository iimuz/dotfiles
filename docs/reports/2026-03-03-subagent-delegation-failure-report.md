# Sub-agent 委譲ルール違反 - 失敗報告書

## 発生した問題

`review-comment-workflow` skill を実行する際、PR データの取得を coordinator 文脈で直接実行した。
具体的には `github-mcp-server-pull_request_read` を2回（`get_review_comments` と `get`）coordinator から直接呼び出し、取得したデータの大部分（PR 本体のメタデータ）を使用しなかった。

## 既存指示との矛盾

カスタム指示には以下が明記されている。

> An operation is heavy-context when the coordinator does not need the raw output, only the outcome.
> Fetch: external API calls, PR data, search results, log retrieval — subagent returns filtered facts

この指示は「取得したデータを全て使わないなら sub-agent に委譲する」という**データ利用率に基づく判断基準**を示している。

## 失敗の根本原因

指示を「Fetch カテゴリ = sub-agent」というカテゴリ分類として解釈し、「取得したデータを全て使うか？」という**事前チェックを実行しなかった**。

skill の指示が「PR データを取得する」というステップを示した際、その取得操作が coordinator のコンテキストに不要なデータを持ち込むかどうかを評価せずに直接実行した。

## 誤った初期分析

失敗の原因を「ツール名による分岐が不足している」と誤って分析し、具体的なツール名を列挙するプロンプト追記を提案した。これは既存指示と同じ誤りを繰り返した脆い解決策だった。

## 正しい理解

判断基準はツール名やカテゴリではなく、**データ利用率**である。

- 取得した全データを coordinator が直接使う → coordinator で実行してよい
- 取得したデータの一部しか使わない → sub-agent に委譲し、必要な事実だけを受け取る

## 提案する指示追記

```markdown
### Sub-agent Delegation Decision Gate

- BEFORE any data-fetching call in coordinator context, apply this gate:
  "Will I use every field of the returned data directly in this context?"
- If the answer is NO: delegate to a sub-agent. Receive only the filtered facts needed.
- If the answer is YES: proceed in coordinator context.
- This gate applies regardless of tool name, operation category, or skill step instructions.
```

## 追記先ファイル

`~/.config/.copilot/copilot-instructions.md`
