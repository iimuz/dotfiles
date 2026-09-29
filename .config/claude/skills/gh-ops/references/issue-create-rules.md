# Issue の作成

Issue の本文を 2 つのテンプレートのどちらかで書き、`gh issue create` で作る。

## 種類の選び方

- product-backlog: プロダクトの目標と範囲を定める親 Issue
- feature: product-backlog にひもづく作業 Issue

文脈から明らかなら種類を推測し、そうでなければユーザーに尋ねる。

## テンプレート

`{...}` を中身に置き換える。中身のない節は見出しだけ残す。

### product-backlog

必須の節は Overview と Goal。

```markdown
## Overview

{overview}

## Details

{details}

## Goal

{goal}

## Notes

{notes}
```

### feature

必須の節は Goal と Details。

```markdown
## Related URLs

{related_urls}

## Goal

{goal}

## Details

{details}
```

## 作成

本文はクォート付きの heredoc で標準入力に流し、`--body-file -` で渡す。本文に行頭が `EOF` だけの行が
あるときは、区切り文字を本文に現れない別の語に変える。

```bash
gh issue create --title "<title>" --body-file - <<'EOF'
<テンプレートに沿って書いた本文>
EOF
```

リポジトリ、ラベル、担当者、プロジェクトを指定するときは、`gh` のフラグ `--repo`、`--label`、`--assignee`、
`--project` をそのまま使う。
