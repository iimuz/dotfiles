# qmd skill の取り込み手順

この skill は qmd に同梱された skill(`qmd skill show` の出力)をベースに、ローカルの追加を加えたもの。
ここには bundled 側の更新を取り込む人向けの手順を書く。

## ベース版

- ベースにした bundled skill のバージョンは SKILL.md の `metadata.version` を見る

## ローカル追加分

- `## 日本語コーパスでの指針` 節
- `## GPU 判定` 節
- `scripts/check_gpu.sh`

## 取り込み手順

- `qmd skill show` の出力を一時ファイルに保存し、`mise run format` を通してから SKILL.md と差分を取る
- コミット済みの SKILL.md は format 済みなので、素の出力と比べると整形差分がノイズとして出る
- 取り込んだら SKILL.md の `metadata.version` を新しいベース版に合わせる

## 取り込まない内容

- CLI 経由の検索と取得に関係しない内容は、bundled 側に含まれていても取り込まない
- 例: MCP サーバーのセットアップ手順、MCP ツール専用の使い方

## 維持する意図的な差分

- Typical loop 節と Retrieve sources 節の `multi-get "#docid,#docid"` を、`qmd://` のカンマ区切りパス形式に
  置き換えている
- docid のカンマ指定は解決に失敗するため、取り込み時もこの置き換えを残す
