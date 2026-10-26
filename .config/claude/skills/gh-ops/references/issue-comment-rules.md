# Issue へのコメント

要約と、0 個以上の折りたたむ節からなるコメントを書き、`gh issue comment` で投稿する。

## テンプレート

要約のあとに、折りたたむ節を 0 個以上並べる。`{...}` を中身に置き換える。

```markdown
{summary}

<details>
<summary>{label}</summary>

{content}

</details>
```

- 要約だけで結論と次の行動が分かるように書く
- `{label}` に `<` と `>` を含めない
- 本文が 65536 文字を超えるときは、折りたたむ節を短くする

## 投稿

```bash
gh issue comment <number> [--repo OWNER/REPO] --body-file - <<'EOF'
<テンプレートに沿って書いた本文>
EOF
```
