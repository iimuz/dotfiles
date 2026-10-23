# ja-sentence-lines

日本語の Markdown の段落の中の改行を、文の終わり (`。`、`！`、`？`) ごとに揃える。
日本語の文字を含む段落、箇条書きの項目の本文、引用の本文だけを書き換える。
コードブロック、インラインコード、表、frontmatter、HTML、見出し、リンクの中には触れない。

## 使い方

- `ja-sentence-lines FILE...`: ファイル全体を揃えて書き戻す
- `ja-sentence-lines --changed FILE...`: git の index と HEAD の差分で変わった段落だけを揃えて書き戻す。
  pre-commit から呼ぶ
- `ja-sentence-lines`: 標準入力の本文を揃えて標準出力に出す

`setup_mac.sh` と `setup_aarch64.sh` が `~/.local/bin/ja-sentence-lines` にリンクを張る。
依存は uv が script のメタデータから入れるので、PATH に uv が要る。

## リポジトリに入れる

commit のたびに、その commit で変えた段落だけを揃える。
job は自分用の lefthook のローカル設定 (`lefthook-local.yml`) にだけ置き、チーム共通の設定には足さない。
チーム共通の設定に足すと、道具を入れていない人の commit が失敗する。

次のリポジトリには入れない。

- prettier の `proseWrap` が `always` か `never` のリポジトリ
- dprint の `textWrap` が `always` か `never` のリポジトリ
- 行長の lint (markdownlint の MD013 など) で Markdown の行の長さに上限を決めているリポジトリ

前の 2 つでは、改行を決める整形と、整形のたびに改行が往復する。
`preserve` や `maintain` は改行を保つので一緒に使える。
行長の lint があると、1 文 1 行の長い行が上限を超えて lint が通らない。
lint の設定はリポジトリの決まりなので、この道具のために変えない。

### 手順

1. リポジトリの直下の `lefthook-local.yml` に次を書く。
   ファイルがすでにあれば、`pre-commit` の `jobs` に job を足す

   ```yaml
   pre-commit:
     parallel: false
     jobs:
       - name: ja-sentence-lines
         glob: "*.md"
         stage_fixed: true
         run: ja-sentence-lines --changed {staged_files}
   ```

2. git の hook がまだ入っていなければ `lefthook install` を走らせる。
   `lefthook.yml` が無いリポジトリでは、`lefthook install` が見本の `lefthook.yml` を作るので消す。
   消しても `lefthook-local.yml` だけで job が動く
3. 日本語の段落を変えて commit し、変えた段落が 1 文 1 行に揃って commit されることを見る

`lefthook-local.yml` は dotfiles の `.config/git/ignore` がグローバルに無視するので、commit されない。

### job の置き方

`parallel: false` は、チーム共通の設定が `pre-commit` に書いた `parallel: true` を手元でだけ上書きする。
この job が prettier などのほかの整形の job と同時に同じファイルを書き換えないようにするためである。
チーム共通の設定の group の中の並列は変わらない。
ローカル設定の job は、チーム共通の設定の job の後に動く。

### ワークツリー

`lefthook-local.yml` はチェックアウトごとのファイルで、ワークツリーでは元のチェックアウトのものが読まれない。
Claude Code が作るワークツリーに写すには、リポジトリの直下の `.worktreeinclude` に `lefthook-local.yml` の 1 行を書く。
グローバルの除外設定で無視されたファイルも写り、`.worktreeinclude` は commit しなくても読まれる。
`.worktreeinclude` を commit しないときは `.git/info/exclude` に足す。
Claude Code 以外の方法で作ったワークツリーには、`lefthook-local.yml` を手で写す。

## Claude Code の hook

`.config/claude/hooks/ja_sentence_lines.py` は、Claude Code が `.md` を書いたり編集したりした後に動く。
git が追跡していないファイル (未追跡か gitignore されたもの) だけを、ファイル全体で揃える。
追跡されているかは、シンボリックリンクをたどった実体のパスで判定する。
動くのは、`lefthook-local.yml` に `ja-sentence-lines` を書いたリポジトリでだけである。
追跡されているファイルは commit 時の job に任せる。
