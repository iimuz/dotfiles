FROM public.ecr.aws/lts/ubuntu:24.04_stable

ARG USERNAME=ubuntu

# Install tools
RUN apt-get update && apt-get install -y \
    build-essential \
    ca-certificates \
    curl \
    git \
    git-delta \
    gzip \
    tar \
    wget \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Set locale
RUN apt-get update && apt-get install -y \
    locales \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV LC_CTYPE=en_US.UTF-8

# Install GitHub CLI
RUN set -eu \
    && (type -p wget >/dev/null || (apt update && apt install wget -y)) \
    && mkdir -p -m 755 /etc/apt/keyrings \
    && out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    && cat $out | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
    && chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && mkdir -p -m 755 /etc/apt/sources.list.d \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt update \
    && apt install gh -y \
    && rm -rf /var/lib/apt/lists/*

# Install Lazygit
RUN set -eu \
  && LAZYGIT_VERSION=0.56.0 \
  && curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_arm64.tar.gz" \
  && tar xf lazygit.tar.gz lazygit \
  && install lazygit -D -t /usr/local/bin/

# Install Neovim
RUN NVIM_VERSION=v0.11.5 \
    && NVIM_FILENAME=nvim-linux-arm64 \
    && TAR_FILENAME=$NVIM_FILENAME.tar.gz \
    && curl -LO https://github.com/neovim/neovim/releases/download/$NVIM_VERSION/$TAR_FILENAME \
    && tar -xzf $TAR_FILENAME \
    && mv $NVIM_FILENAME /opt/nvim \
    && ln -s /opt/nvim/bin/nvim /usr/bin/nvim \
    && rm $TAR_FILENAME

RUN set -eu \
    && mkdir -p /workspace \
    && chown -R $USERNAME:$USERNAME /home/$USERNAME \
    && chown -R $USERNAME:$USERNAME /workspace

USER $USERNAME

# Dotfiles
COPY --chown=$USERNAME:$USERNAME . /home/$USERNAME/dotfiles
RUN SRC=/home/$USERNAME/dotfiles/.config \
    && DST=/home/$USERNAME/.config \
    && BASHRC=/home/$USERNAME/.bashrc \
    && mkdir -p $DST \
    && mkdir $DST/git \
    && ln -s $(realpath $SRC/../.gitconfig) /home/$USERNAME/.gitconfig \
    && ln -s $SRC/git/ignore $DST/git/ignore \
    && mkdir $DST/lazygit \
    && ln -s $SRC/lazygit/config.yml $DST/lazygit/config.yml \
    && ln -s $SRC/nvim/ $DST/nvim \
    && : "terminal で <Ctrl + h> で backspace となるように設定" \
    && echo 'stty erase ^H' >> $BASHRC \
    && echo ". $SRC/rc-settings.sh" >> $BASHRC \
    : "対応: detected dubious ownership in repository at" \
    && git config --global --add safe.directory /workspace

# Setup Neovim plugins
RUN nvim --headless "+Lazy! sync" +qa \
    && nvim --headless "+MasonToolsInstallSync" +qa \
    && nvim --headless "+TSUpdateSync" +qa

WORKDIR /workspace
