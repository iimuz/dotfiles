FROM public.ecr.aws/lts/ubuntu:24.04_stable

ARG USERNAME=ubuntu

# Install tools
RUN apt-get update && apt-get install -y \
    build-essential \
    ca-certificates \
    curl \
    git \
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

# Install Node.js
RUN NODE_VERSION=22.21.0 \
    && ARCH=$(uname -m) \
    && if [ "$ARCH" = "aarch64" ]; then NODE_ARCH="arm64"; else NODE_ARCH="x64"; fi \
    && curl -LO https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${NODE_ARCH}.tar.xz \
    && tar -xJf node-v${NODE_VERSION}-linux-${NODE_ARCH}.tar.xz \
    && mv node-v${NODE_VERSION}-linux-${NODE_ARCH} /opt/node \
    && ln -s /opt/node/bin/node /usr/bin/node \
    && ln -s /opt/node/bin/npm /usr/bin/npm \
    && ln -s /opt/node/bin/npx /usr/bin/npx \
    && rm node-v${NODE_VERSION}-linux-${NODE_ARCH}.tar.xz \
    && npm cache clean --force

# Install Python
# patch version を指定してインストールはできない
RUN PYTHON_VERSION=3.11 \
    && apt-get update && apt-get install -y \
    software-properties-common \
    && add-apt-repository ppa:deadsnakes/ppa -y \
    && apt-get update \
    && apt-get install -y \
        python${PYTHON_VERSION} \
        python${PYTHON_VERSION}-dev \
        python${PYTHON_VERSION}-venv \
        python3-pip \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python${PYTHON_VERSION} 1 \
    && update-alternatives --install /usr/bin/python python /usr/bin/python${PYTHON_VERSION} 1 \
    && rm -rf /var/lib/apt/lists/* \
    && python3 -m pip cache purge

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

RUN set -eu \
    && mkdir -p /workspace \
    && chown -R $USERNAME:$USERNAME /home/$USERNAME \
    && chown -R $USERNAME:$USERNAME /workspace

USER $USERNAME

# Install global npm packages
# ここでは opt にフォルダを作成するため COPY で実施する
ENV NPM_GLOBAL_DIR=/opt/npm-global
COPY --chown=$USERNAME:$USERNAME ./.config/docker/dcopilot/package*.json $NPM_GLOBAL_DIR/
RUN cd $NPM_GLOBAL_DIR \
    && npm ci --ignore-scripts \
    && npm cache clean --force
ENV PATH="$NPM_GLOBAL_DIR/node_modules/.bin:$PATH"
ENV NODE_PATH="$NPM_GLOBAL_DIR/node_modules:$NODE_PATH"
RUN safe-chain setup --include-python

# Install global python packages for Neovim
ENV PIP_GLOBAL_DIR=/opt/pip-global
COPY --chown=$USERNAME:$USERNAME ./.config/docker/dcopilot/requirements-freeze.txt $PIP_GLOBAL_DIR/
RUN cd $PIP_GLOBAL_DIR \
    && pip install --no-cache-dir -r requirements-freeze.txt

# Dotfiles
COPY --chown=$USERNAME:$USERNAME . /home/$USERNAME/dotfiles
RUN set -eu \
    && SRC=/home/$USERNAME/dotfiles/.config \
    && DST=/home/$USERNAME/.config \
    && SELFRC=/home/$USERNAME/.selfrc \
    && mkdir -p $DST \
    && mkdir $DST/git \
    && ln -s $(realpath $SRC/../.gitconfig) /home/$USERNAME/.gitconfig \
    && ln -s $SRC/git/ignore $DST/git/ignore \
    && mkdir $DST/.copilot \
    && ln -s $(realpath $SRC/copilot/agents) "$DST/.copilot/agents" \
    && ln -s $(realpath $SRC/copilot/config.json) "$DST/.copilot/config.json" \
    && ln -s $(realpath $SRC/copilot/mcp-config.json) "$DST/.copilot/mcp-config.json" \
    && : "terminal で <Ctrl + h> で backspace となるように設定" \
    && echo 'stty erase ^H' >> $SELFRC \
    && echo ". $SRC/rc-settings.sh" >> $SELFRC \
    && echo ". $SELFRC" >> "/home/$USERNAME/.bashrc"

COPY --chown=$USERNAME:$USERNAME ./.config/docker/dcopilot/entrypoint.sh /home/$USERNAME/entrypoint.sh
RUN chmod +x /home/$USERNAME/entrypoint.sh
ENTRYPOINT ["/home/ubuntu/entrypoint.sh"]

WORKDIR /workspace
CMD ["bash"]
