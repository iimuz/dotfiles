# echo用の色を設定します
NML_COLOR='\033[1;33m'
NC='\033[0m'

# etcのbashrcを読み込む
echo -e "${NML_COLOR}Load /etc/bashrc${NC}"

# プロンプトの表示形式を設定
PS1="[\u@\h \W]\$"

# alias
## lsを色つきにします
alias ls='ls -G'
## git logのエイリアスを作成します
alias gitlg='git log --graph --oneline --decorate=full --branches --tags --remotes'

