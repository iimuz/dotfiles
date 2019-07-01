FROM node:8.16.0-stretch AS base

ENV DEBIAN_FRONTEND=noninteractive
RUN set -x \
  && : "Configure apt" \
  && apt-get update \
  && apt-get install -y --no-install-recommends apt-utils 2>&1 \
  && apt-get autoremove -y \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/*

RUN set -x \
  && : "Verify git and needed tools are installed" \
  && apt-get update \
  && apt-get install -y \
    git \
    procps \
  && apt-get autoremove -y \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/*

RUN set -x \
  && : "Remove outdated yarn from /opt and install via package" \
  && : "so it can be easily updated via apt-get upgrade yarn" \
  && rm -rf /opt/yarn-* \
  && rm -f /usr/local/bin/yarn \
  && rm -f /usr/local/bin/yarnpkg \
  && apt-get update \
  && apt-get install -y curl apt-transport-https lsb-release \
  && curl -sS https://dl.yarnpkg.com/$(lsb_release -is | tr '[:upper:]' '[:lower:]')/pubkey.gpg | apt-key add - 2>/dev/null \
  && echo "deb https://dl.yarnpkg.com/$(lsb_release -is | tr '[:upper:]' '[:lower:]')/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
  && apt-get update \
  && apt-get -y install --no-install-recommends yarn \
  && apt-get autoremove -y \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/*

RUN set -x \
  && : "Install other development tools" \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    gpg \
  && chmod +x /usr/share/doc/git/contrib/credential/netrc/git-credential-netrc \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
COPY .bashrc /root/.bashrc
COPY .gitconfig /root/.gitconfig

RUN set -x \
  : "Install eslint" \
  && npm install -g eslint

ENV DEBIAN_FRONTEND=dialog \
  SHELL=/bin/bash \
  HOME=/root
WORKDIR /workspace
CMD ["sleep", "infinity"]

FROM base AS withUser

ARG GROUP_ID=1000
ARG USER_ID=1000
ARG USER_NAME=dev
RUN set -x && \
  : "Add user account" && \
  groupadd -g $GROUP_ID $USER_NAME && \
  useradd -m -u $USER_ID -g $USER_NAME $USER_NAME && \
  chsh -s /bin/bash $USER_NAME

USER dev
ENV HOME=/home/$USER_NAME
COPY .bashrc $HOME/.bashrc
COPY .gitconfig $HOME/.gitconfig
