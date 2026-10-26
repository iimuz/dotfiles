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
job の置き場所は、リポジトリをチームで管理しているか、自分だけが使うかで分ける。

次のリポジトリには入れない。
チームで管理するリポジトリにも、自分だけが使うリポジトリにも掛かる。

- prettier の `proseWrap` が `always` か `never` のリポジトリ
- dprint の `textWrap` が `always` か `never` のリポジトリ
- 行長の lint (markdownlint の MD013 など) で Markdown の行の長さに上限を決めているリポジトリ

前の 2 つでは、改行を決める整形と、整形のたびに改行が往復する。
`preserve` や `maintain` は改行を保つので一緒に使える。
行長の lint があると、1 文 1 行の長い行が上限を超えて lint が通らない。
lint の設定はリポジトリの決まりなので、この道具のために変えない。

### チームで管理するリポジトリ

job は自分用の lefthook のローカル設定 (`lefthook-local.yml`) にだけ置き、チーム共通の設定には足さない。
チーム共通の設定に足すと、道具を入れていない人の commit が失敗する。

#### 手順

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

#### job の置き方

`parallel: false` は、チーム共通の設定が `pre-commit` に書いた `parallel: true` を手元でだけ上書きする。
この job が prettier などのほかの整形の job と同時に同じファイルを書き換えないようにするためである。
チーム共通の設定の group の中の並列は変わらない。
ローカル設定の job は、チーム共通の設定の job の後に動く。

#### ワークツリー

`lefthook-local.yml` はチェックアウトごとのファイルで、ワークツリーでは元のチェックアウトのものが読まれない。
Claude Code が作るワークツリーに写すには、リポジトリの直下の `.worktreeinclude` に `lefthook-local.yml` の 1 行を書く。
グローバルの除外設定で無視されたファイルも写り、`.worktreeinclude` は commit しなくても読まれる。
`.worktreeinclude` を commit しないときは `.git/info/exclude` に足す。
Claude Code 以外の方法で作ったワークツリーには、`lefthook-local.yml` を手で写す。

### 自分だけが使うリポジトリ

job は `lefthook.yml` に直接書く。
`lefthook.yml` は commit されるので、どのワークツリーにも入り、ワークツリーへ写す手間が無い。
道具を入れていない環境では commit が失敗するので、この置き方は自分だけが使うリポジトリに限る。

#### 手順

1. Markdown の整形の job が無ければ、リポジトリの直下の `lefthook.yml` の `pre-commit` の `jobs` に次の job を足すだけでよい。
   `lefthook.yml` がまだ無ければ、この内容で作る

   ```yaml
   pre-commit:
     jobs:
       - name: ja-sentence-lines
         glob: "*.md"
         stage_fixed: true
         run: ja-sentence-lines --changed {staged_files}
   ```

2. Markdown の整形の job があれば、その job と `ja-sentence-lines` を `piped: true` の group にまとめ、整形の job の後に並べる。
   整形の job が `parallel: true` の group の中にあれば、`piped: true` の group をその中に置く。
   job の名前と整形のコマンドは例である

   ```yaml
   pre-commit:
     jobs:
       - name: format
         group:
           parallel: true
           jobs:
             # ほかの整形の job
             - name: format-md
               group:
                 piped: true
                 jobs:
                   - name: prettier
                     glob: "*.md"
                     stage_fixed: true
                     run: prettier --write {staged_files}
                   - name: ja-sentence-lines
                     glob: "*.md"
                     stage_fixed: true
                     run: ja-sentence-lines --changed {staged_files}
   ```

3. git の hook がまだ入っていなければ `lefthook install` を走らせる
4. 日本語の段落を変えて commit し、変えた段落が 1 文 1 行に揃って commit されることを見る

#### job の置き方

`piped: true` の group の中の job は、上から順に 1 つずつ動く。
`ja-sentence-lines` を整形の job の後に並べるのは、prettier などと同時に同じファイルを書き換えないためである。
`parallel: true` の group の中に入れても、`piped: true` の group の job は互いに直列に動き、外側の group のほかの job とは並列に動く。
`piped: true` は、前の job が失敗すると後の job を飛ばす。
整形が失敗したら揃える意味が無いので、それでよい。

## Claude Code の hook

`.config/claude/hooks/ja_sentence_lines.py` は、Claude Code が `.md` を書いたり編集したりした後に動く。
git が追跡していないファイル (未追跡か gitignore されたもの) だけを、ファイル全体で揃える。
追跡されているかは、シンボリックリンクをたどった実体のパスで判定する。
動くのは、lefthook が読む設定ファイルのどれかに `ja-sentence-lines` を書いたリポジトリでだけである。
設定ファイルの名前は、リポジトリのルートからの相対パスで `lefthook`、`.lefthook`、`.config/lefthook` と、それぞれの末尾に `-local` を付けたものである。
拡張子は `.yml`、`.yaml`、`.json`、`.jsonc`、`.toml` のどれかである。
lefthook は、メインの設定 (`-local` の付かない名前) とローカル設定 (`-local` の付く名前) のそれぞれで、最初に見つけた 1 つだけを読む。
hook はその順を真似せず、どれか 1 つに道具の名前があれば動く。
設定を解析せず文字列を含むかだけを見るので、コメントの中の名前でも動く。
`extends` や `remotes` で読み込まれる設定は見ない。
追跡されているファイルは commit 時の job に任せる。
