#!/bin/sh

VERSION=0.5.3
ARCH=amd64
FILE_DIR=peco_linux_${ARCH}
FILENAME=${FILE_DIR}.tar.gz

MAIN_BASHRC=~/.bashrc
ALIAS_DIR=~/.config/peco
ALIAS_BASHRC=${ALIAS_DIR}/alias.bash.inc

# download ghq
wget https://github.com/peco/peco/releases/download/v${VERSION}/${FILENAME}
tar xvzf $FILENAME
sudo mv $FILE_DIR/peco /usr/local/bin/
rm -rf $FILE_DIR $FILENAME

# settings
cat <<EOF >> $MAIN_BASHRC

# The next line enables shell alias command using peco.
if [ -f '${ALIAS_BASHRC}' ]; then . '${ALIAS_BASHRC}'; fi
EOF

mkdir -p $ALIAS_DIR
cat <<EOF >> $ALIAS_BASHRC
# ghq
alias ffghq='cd \$(ghq root)/\$(ghq list | peco)'

# git
alias ffgb='\`git branch | peco --prompt "GIT BRANCH>" | head -n 1 | sed -e "s/^\*\s*//g"\`'

# history
export HISTCONTROL="ignoredups"
peco-history() {
  local NUM=\$(history | wc -l)
  local FIRST=\$((-1*(NUM-1)))

  if [ \$FIRST -eq 0 ] ; then
    history -d \$((HISTCMD-1))
    echo "No history" >&2
    return
  fi

  local CMD=\$(fc -l \$FIRST | sort -k 2 -k 1nr | uniq -f 1 | sort -nr | sed -E 's/^[0-9]+[[:blank:]]+//' | peco | head -n 1)

  if [ -n "\$CMD" ] ; then
    history -s \$CMD

    READLINE_LINE="\${CMD}"
    READLINE_POINT=\${#CMD}
  else
    history -d \$((HISTCMD-1))
  fi
}
bind -x '"\C-r":peco-history'
EOF

. $MAIN_BASHRC
