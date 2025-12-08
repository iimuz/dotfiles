FROM public.ecr.aws/lts/ubuntu:24.04_stable

ARG USERNAME=ubuntu

ENV SELFRC="/home/$USERNAME/.selfrc"

# Install tools
RUN apt-get update && apt-get install -y \
    build-essential \
    ca-certificates \
    curl \
    fd-find \
    git \
    git-delta \
    gzip \
    passwd \
    ripgrep \
    tar \
    wget \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

ARG UID=1000
ARG GID=1000
RUN groupmod -g $GID $USERNAME \
    && usermod -u $UID -g $GID $USERNAME \
    && chown -R $UID:$GID /home/$USERNAME

# Set locale
RUN apt-get update && apt-get install -y \
    locales \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV LC_CTYPE=en_US.UTF-8

# Install zsh
RUN apt-get update && apt-get install -y curl zsh \
    && chsh -s /bin/zsh $USERNAME \
    && rm -rf /var/lib/apt/lists/*
ENV SHELL=/bin/zsh

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

RUN set -eu \
  && mise settings set experimental true \
  && mise settings set pipx.uvx true \
  && mise use -g go@1.25.5 \
  && mise use -g rust@stable \
  && mise use -g starship@1.24.1 \
  && mise use -g node@22.21.1 \
  && mise use -g npm:@aikidosec/safe-chain@1.1.10 \
  && mise use -g python@3.13.11 \
  && mise use -g uv@0.9.15

# Install copilot tools
RUN set -eu \
  && mise use -g gh@2.83.1 \
  && mise use -g npm:@github/copilot@0.0.367 \
  && mise use -g pipx:oraios/serena@v0.1.4 \
  && mise use -g pipx:markitdown-mcp@0.0.1a4 \
  && mise use -g npm:mcp-remote@0.1.31

# go tools を mise で入れると一部適切にインストールできない時があるので、普通にインストール
RUN set -eu \
    && go install github.com/rakyll/gotest@v0.0.6 \
    && go install github.com/fatih/gomodifytags@v1.17.0 \
    && go install github.com/josharian/impl@v1.4.0 \
    && go install github.com/haya14busa/goplay/cmd/goplay@v1.0.0 \
    && go install github.com/go-delve/delve/cmd/dlv@v1.25.2 \
    && go install golang.org/x/tools/gopls@v0.20.0 \
    && go install gotest.tools/gotestsum@v1.13.0
ENV PATH="/home/$USERNAME/go/bin:$PATH"

# Dotfiles
COPY --chown=$USERNAME:$USERNAME . /home/$USERNAME/dotfiles
COPY --chown=$USERNAME:$USERNAME ./.config/docker/dcopilot/rc-settings.sh /home/$USERNAME/dotfiles/.config/rc-settings.sh
COPY --chown=$USERNAME:$USERNAME ./.config/bash /home/$USERNAME/dotfiles/.config/bash
COPY --chown=$USERNAME:$USERNAME ./.config/copilot /home/$USERNAME/dotfiles/.config/copilot
COPY --chown=$USERNAME:$USERNAME ./.config/git /home/$USERNAME/dotfiles/.config/git
COPY --chown=$USERNAME:$USERNAME ./.config/go /home/$USERNAME/dotfiles/.config/go
COPY --chown=$USERNAME:$USERNAME ./.config/mise/mise-settings.sh /home/$USERNAME/dotfiles/.config/mise/mise-settings.sh
COPY --chown=$USERNAME:$USERNAME ./.config/node /home/$USERNAME/dotfiles/.config/node
COPY --chown=$USERNAME:$USERNAME ./.config/python /home/$USERNAME/dotfiles/.config/python
COPY --chown=$USERNAME:$USERNAME ./.config/starship /home/$USERNAME/dotfiles/.config/starship
COPY --chown=$USERNAME:$USERNAME ./.gitconfig /home/$USERNAME/.gitconfig
RUN set -eu \
    && SRC=/home/$USERNAME/dotfiles/.config \
    && DST=/home/$USERNAME/.config \
    && mkdir -p $DST \
    && mkdir $DST/git \
    && ln -s $SRC/git/ignore $DST/git/ignore \
    && mkdir $DST/.copilot \
    && ln -s $(realpath $SRC/copilot/agents) "$DST/.copilot/agents" \
    && ln -s $(realpath $SRC/copilot/config.json) "$DST/.copilot/config.json" \
    && ln -s $(realpath $SRC/copilot/mcp-config.json) "$DST/.copilot/mcp-config.json" \
    && : "terminal で <Ctrl + h> で backspace となるように設定" \
    && echo 'stty erase ^H' >> $SELFRC \
    && echo ". $SRC/rc-settings.sh" >> $SELFRC \
    && echo ". $SELFRC" >> "/home/$USERNAME/.zshrc"

COPY --chown=$USERNAME:$USERNAME ./.config/docker/dcopilot/entrypoint.sh /home/$USERNAME/entrypoint.sh
RUN chmod +x /home/$USERNAME/entrypoint.sh
ENTRYPOINT ["/home/ubuntu/entrypoint.sh"]

WORKDIR /workspace
CMD ["copilot"]
