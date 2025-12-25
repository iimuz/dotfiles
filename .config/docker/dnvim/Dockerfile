FROM public.ecr.aws/lts/ubuntu:24.04_stable

ARG USERNAME=ubuntu

ENV SELFRC="/home/$USERNAME/.selfrc"

# Install tools
# - libicu74: marksman で必要
RUN set -eu \
    && apt-get update && apt-get install -y \
        build-essential \
        ca-certificates \
        curl \
        fd-find \
        git \
        git-delta \
        gzip \
        jq \
        libicu74 \
        libreadline-dev \
        ripgrep \
        tar \
        unzip \
        vifm \
        wget \
        xclip \
        xz-utils \
        passwd \
    && rm -rf /var/lib/apt/lists/*

ARG UID=1000
ARG GID=1000
RUN set -eu \
    && groupmod -g $GID $USERNAME \
    && usermod -u $UID -g $GID $USERNAME \
    && chown -R $UID:$GID /home/$USERNAME

# Set locale
RUN set -eu \
    && apt-get update && apt-get install -y locales \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV LC_CTYPE=en_US.UTF-8

# Set timezone
RUN set -eu \
    && apt-get update && apt-get install -y tzdata \
    && rm -rf /var/lib/apt/lists/*
ENV TZ=Asia/Tokyo
RUN set -eu \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone

# Install zsh
RUN apt-get update && apt-get install -y curl zsh \
    && chsh -s /bin/zsh $USERNAME \
    && rm -rf /var/lib/apt/lists/*
ENV SHELL=/bin/zsh

# Install gh command
# gh command で git 認証しているため、 mise でインストールすると動作失敗するケースがあったのでネイティブでインストール
RUN set -eu \
    && apt-get update \
    && apt-get install -y wget \
    && mkdir -p -m 755 /etc/apt/keyrings \
    && out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    && cat $out | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
    && chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && mkdir -p -m 755 /etc/apt/sources.list.d \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install gh -y \
    && rm -rf /var/lib/apt/lists/*

# Install Mise
ENV MISE_DATA_DIR="/mise"
ENV MISE_CONFIG_DIR="/mise"
ENV MISE_CACHE_DIR="/mise/cache"
ENV MISE_INSTALL_PATH="/usr/local/bin/mise"
ENV PATH="/mise/shims:$PATH"
RUN set -eu \
    && MISE_VERSION=v2025.11.11 \
    && curl https://mise.jdx.dev/install.sh | sh \
    && mkdir "$MISE_DATA_DIR" \
    && chown -R $USERNAME:$USERNAME "$MISE_DATA_DIR"

RUN set -eu \
    && chown -R $USERNAME:$USERNAME /home/$USERNAME \
    && mkdir /workspace \
    && chown -R $USERNAME:$USERNAME /workspace

USER $USERNAME

# Add path
ENV PATH="$HOME/.local/bin/:$PATH"
ENV PATH="$HOME/go/bin:$PATH"

# Install tools
RUN set -eu \
    && mise settings set experimental true \
    && mise settings set pipx.uvx true \
    && mise use -g awscli@2.31.39 \
    && mise use -g lazygit@0.57.0 \
    && mise use -g starship@1.24.1 \
    && mise use -g yq@4.49.2

ENV FZF_CONFIG=/home/$USERNAME/fzf
RUN set -eu \
    && mise use -g fzf@0.67.0 \
    && mkdir $FZF_CONFIG \
    && curl -fLo $FZF_CONFIG/completion.zsh https://raw.githubusercontent.com/junegunn/fzf/v0.67.0/shell/completion.zsh \
    && curl -fLo $FZF_CONFIG/key-bindings.zsh https://raw.githubusercontent.com/junegunn/fzf/v0.67.0/shell/key-bindings.zsh

# Install go language
RUN set -eu \
    && mise use -g go@1.25.5 \
    && mise use -g golangci-lint@2.7.2 \
    && go install github.com/jesseduffield/lazygit@v0.56.0 \
    && go install github.com/rakyll/gotest@v0.0.6 \
    && go install github.com/fatih/gomodifytags@v1.17.0 \
    && go install github.com/josharian/impl@v1.4.0 \
    && go install github.com/haya14busa/goplay/cmd/goplay@v1.0.0 \
    && go install github.com/go-delve/delve/cmd/dlv@v1.25.2 \
    && go install golang.org/x/tools/gopls@v0.20.0 \
    && go install gotest.tools/gotestsum@v1.13.0
ENV PATH="/home/$USERNAME/go/bin:$PATH"

# Install lua
# neovim luarocksで要求しているバージョンが5.1
RUN set -eu \
    && mise use -g lua@5.1.5

# Install node.js
# docker 環境での node.js は volta で設定する。
# mise でインストールした node.js で global tool をインストールすると、
# mise による node.js のバージョン設定で global tool が使えなくなることがあるため、 node.js の global tool は volta でインストールする。
ENV VOLTA_HOME="/home/$USERNAME/.volta" \
    PATH="/home/$USERNAME/.volta/bin:$PATH"
RUN set -eu \
    && curl -fsSL https://get.volta.sh | bash \
    && volta install node@22.21.1 \
    && mise use -g node@22.21.1 \
    && npm install -g @aikidosec/safe-chain@1.1.10

# Install python
RUN set -eu \
    && mise use -g python@3.13.11 \
    && mise use -g uv@0.9.15

# Install rust
RUN set -eu \
    && mise use -g rust@1.91.1

RUN set -eu \
    && npm install -g @github/copilot@0.0.372 \
    && uv tool install git+https://github.com/oraios/serena@v0.1.4 \
    && uv tool install markitdown-mcp==0.0.1a4

# Install jwt cli
RUN set -eu \
    && cargo install jwt-cli@6.2.0

# Install k8s
RUN set -eu \
    && mise use -g kind@0.30.0 \
    && mise use -g kubectl@1.34.3

# Install neovim
RUN set -eu \
    && mise use -g neovim@0.11.5 \
    && npm install -g mcp-hub@4.2.1 \
    && npm install -g neovim@5.4.0 \
    && uv tool install pynvim@0.6.0

# Install shell
RUN set -eu \
    && mise use -g shellcheck@0.11.0 \
    && mise use -g shfmt@3.12.0

# Install snowflake
RUN set -eu \
    && uv tool install snowflake-cli@3.14.0

# Dotfiles
COPY --chown=$USERNAME:$USERNAME ./.config/docker/dnvim/rc-settings.sh /home/$USERNAME/dotfiles/.config/rc-settings.sh
COPY --chown=$USERNAME:$USERNAME ./.config/bash /home/$USERNAME/dotfiles/.config/bash
COPY --chown=$USERNAME:$USERNAME ./.config/copilot /home/$USERNAME/dotfiles/.config/copilot
COPY --chown=$USERNAME:$USERNAME ./.config/fzf /home/$USERNAME/dotfiles/.config/fzf
COPY --chown=$USERNAME:$USERNAME ./.config/git /home/$USERNAME/dotfiles/.config/git
COPY --chown=$USERNAME:$USERNAME ./.config/go /home/$USERNAME/dotfiles/.config/go
COPY --chown=$USERNAME:$USERNAME ./.config/lazygit /home/$USERNAME/dotfiles/.config/lazygit
COPY --chown=$USERNAME:$USERNAME ./.config/mise/mise-settings.sh /home/$USERNAME/dotfiles/.config/mise/mise-settings.sh
COPY --chown=$USERNAME:$USERNAME ./.config/node /home/$USERNAME/dotfiles/.config/node
COPY --chown=$USERNAME:$USERNAME ./.config/nvim /home/$USERNAME/dotfiles/.config/nvim
COPY --chown=$USERNAME:$USERNAME ./.config/python /home/$USERNAME/dotfiles/.config/python
COPY --chown=$USERNAME:$USERNAME ./.config/starship /home/$USERNAME/dotfiles/.config/starship
COPY --chown=$USERNAME:$USERNAME ./.config/vifm /home/$USERNAME/dotfiles/.config/vifm
COPY --chown=$USERNAME:$USERNAME ./.gitconfig /home/$USERNAME/.gitconfig
RUN set -eu \
    && SRC=$HOME/dotfiles/.config \
    && DST=$HOME/.config \
    && mkdir -p "$DST" \
    && mkdir "$DST/git" \
    && ln -s $SRC/git/ignore $DST/git/ignore \
    && mkdir $DST/.copilot \
    && ln -s $(realpath $SRC/copilot/agents) "$DST/.copilot/agents" \
    && ln -s $(realpath $SRC/copilot/config.json) "$DST/.copilot/config.json" \
    && ln -s $(realpath $SRC/copilot/mcp-config.json) "$DST/.copilot/mcp-config.json" \
    && mkdir $DST/lazygit \
    && ln -s $SRC/lazygit/config.yml $DST/lazygit/config.yml \
    && ln -s $SRC/nvim/ $DST/nvim \
    && mkdir $DST/vifm \
    && ln -s $SRC/vifm/vifmrc $DST/vifm/vifmrc \
    && safe-chain setup --include-python \
    && echo 'source ~/.safe-chain/scripts/init-posix.sh # Safe-chain Zsh initialization script' >> $SELFRC \
    && : "terminal で <Ctrl + h> で backspace となるように設定" \
    && echo 'stty erase ^H' >> $SELFRC \
    && : "snacks.nvim からファイル削除で gio エラーが発生するため" \
    && echo 'export GIO_USE_TRASH=0' >> $SELFRC \
    && echo "source $SRC/rc-settings.sh" >> $SELFRC \
    && echo "source $SELFRC" >> "/home/$USERNAME/.zshrc"

# Setup Neovim plugins
RUN nvim --headless "+Lazy! sync" +qa \
    && nvim --headless "+MasonToolsInstallSync" +qa \
    && nvim --headless "+TSUpdateSync" +qa

COPY --chown=$USERNAME:$USERNAME ./.config/docker/dnvim/entrypoint.sh /home/$USERNAME/entrypoint.sh
RUN chmod +x /home/$USERNAME/entrypoint.sh
ENTRYPOINT ["/home/ubuntu/entrypoint.sh"]

WORKDIR /workspace
CMD ["nvim"]
