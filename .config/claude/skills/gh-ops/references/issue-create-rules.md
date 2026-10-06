# Issue の作成

Issue の本文を 2 つのテンプレートのどちらかで書き、`gh issue create` で作る。

## 種類の選び方

- product-backlog: プロダクトの目標と範囲を定める親 Issue
- feature: product-backlog にひもづく作業 Issue

文脈から明らかなら種類を推測し、そうでなければユーザーに尋ねる。

## テンプレート

`{...}` を中身に置き換える。中身のない節は見出しだけ残す。

### product-backlog

必須の節は概要とゴール。

```markdown
## 概要

{overview}

## 詳細

{details}

## ゴール

{goal}

## 備考

{notes}
```

### feature

必須の節はゴールと詳細。

```markdown
## 関連 URL

{related_urls}

## ゴール

{goal}

## 詳細

{details}
```

## 作成

```bash
gh issue create --title '<タイトル>' --body-file - <<'EOF'
<テンプレートに沿って書いた本文>
EOF
```

リポジトリ、ラベル、担当者、プロジェクトを指定するときは、`gh` のフラグ `--repo`、`--label`、`--assignee`、
`--project` をそのまま使う。
