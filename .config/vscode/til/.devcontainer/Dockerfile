FROM ubuntu:18.04 AS base
LABEL maintainer "iimuz"

ENV DEBIAN_FRONTEND=noninteractive

RUN set -x \
  && : "Set locale" \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    locales \
    locales-all \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
ENV LC_ALL=en_US.UTF-8 \
  LANG=en_US.UTF-8 \
  LANGUAGE=en_US:en

RUN set -x && \
  : "Install tools for vscode" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    git \
    procps \
    && \
  : "Install any missing dependencies for enhanced language service" && \
  apt-get install -y libicu[0-9][0-9] && \
  chsh -s /bin/bash && \
  : "Clean" && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

ENV PIPENV_VENV_IN_PROJECT=true
COPY requirements.txt /
RUN set -x \
  && : "Install python" \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    python3.7 \
    python3.7-dev \
    python3-pip \
  && : "Set default python command version" \
  && ln -s python3.7 /usr/bin/python \
  && : "Install pipenv" \
  && pip3 install pipenv \
  && : "Install pip tools for vscode" \
  && pip3 install -r requirements.txt \
  && rm requirements.txt* \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN set -x \
  && : "Install other development tools" \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    curl \
    gpg \
    wget \
  && wget https://raw.githubusercontent.com/git/git/v2.23.0/contrib/credential/netrc/git-credential-netrc \
  && mv git-credential-netrc /usr/share/doc/git/contrib/credential/netrc/git-credential-netrc \
  && chmod +x /usr/share/doc/git/contrib/credential/netrc/git-credential-netrc \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
COPY .bashrc /root/.bashrc
COPY .gitconfig /root/.gitconfig

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

