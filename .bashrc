# echo用の色を設定します
NML_COLOR='\033[1;33m'
NC='\033[0m'

# OSを特定します
OS_MAC="Mac"
OS_WIN="Windows_NT"
if [ "$(uname)" == 'Darwin' ]; then
  echo -e "${NML_COLOR}OS is Mac${NC}"
  OS=$OS_MAC
elif [ $OS == $OS_WIN ]; then
  echo -e "${NML_COLOR}OS is Win${NC}"
  # OS=$OS_WIN
fi


# etcのbashrcを読み込む
if [ -f /etc/bashrc ]; then
  # Mac & Linux
  echo -e "${NML_COLOR}Load /etc/bashrc${NC}"
  . /etc/bashrc
elif [ $OS == $OS_WIN ]; then
  # MSYS2
  if [ -f /etc/bash.bashrc ]; then
    echo -e "${NML_COLOR}Load /etc/bash.bashrc${NC}"
    . /etc/bash.bashrc
  fi
fi

# windowsの場合にdocker設定スクリプトを実行します
if [ $OS == $OS_WIN ]; then
  DOCKER_DIR="/c/Program Files/Docker Toolbox"
  if [ -d "${DOCKER_DIR}" ]; then
    echo -e "${NML_COLOR}docker settings for win...${NC}"

    export PATH="${DOCKER_DIR}:$PATH"
    cd "${DOCKER_DIR}"
    DOCKER_MACHINE=./docker-machine.exe
    VM=default
    if [ "$($DOCKER_MACHINE status $VM)" != "Running" ]; then
      echo "Starting machine $VM..."
      $DOCKER_MACHINE start $VM
      yes | $DOCKER_MACHINE regenerate-certs $VM
    fi
    echo "Setting environment variables for machine $VM..."
    eval "$($DOCKER_MACHINE env --shell=bash $VM)"
    cd
  fi
fi

# Macの場合にhomebrewで自動的にbrew-fileをアップデートするようにします
if [ $OS == $OS_MAC ]; then
  if [ -f $(brew --prefix)/etc/brew-wrap ]; then
    . $(brew --prefix)/etc/brew-wrap
  fi
fi

# プロンプトの表示形式を設定
if [ $OS == $OS_MAC ]; then
  PS1="[\u@\h \W]\$"
fi

# alias
## lsを色つきにします
if [ $OS == $OS_MAC ]; then
  alias ls='ls -G'
elif [ $OS == $OS_WIN ]; then
  alias ls='ls --color=auto'
fi

## git logのエイリアスを作成します
alias gitlg='git log --graph --oneline --decorate=full --branches --tags --remotes'


# function
## pecoを利用してcdします
function pcd {
  local dir="$( ls -1d $WORKPATH/src/*/*/* | peco )"
  if [ ! -z "$dir" ] ; then
    cd "$dir"
  fi
}
