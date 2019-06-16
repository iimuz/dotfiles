FROM python:3.7.3-stretch AS base

ENV DEBIAN_FRONTEND noninteractive
RUN set -x  \
  && : "Set locale" \
  && apt-get update \
  && apt-get install -y --no-install-recommends locales \
  && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
  && locale-gen \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
ENV SHELL=/bin/bash \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8

RUN set -x \
  && : "Install tools for vscode" \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    git \
    procps \
  && apt-get install -y libicu[0-9][0-9] \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN set -x \
  && : "Install hugo" \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    wget \
    tar \
  && hugoVersion=0.55.5 \
  && hugoArchive=hugo_${hugoVersion}_Linux-64bit.tar.gz \
  && wget https://github.com/gohugoio/hugo/releases/download/v${hugoVersion}/${hugoArchive} \
  && tar -xvzf $hugoArchive \
  && mv hugo /usr/local/bin/ \
  && rm $hugoArchive \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN set -x \
  && : "Install other development tools" \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    gpg \
    make \
  && : "Set development environments" \
  && chmod +x /usr/share/doc/git/contrib/credential/netrc/git-credential-netrc \
  && chsh -s /bin/bash root \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
COPY .bashrc /root/.bashrc
COPY .gitconfig /root/.gitconfig

COPY requirements.txt /requirements.txt
RUN set -x \
  && : "Install python tools" \
  && pip3 install -r /requirements.txt \
  && rm /requirements.txt

WORKDIR /workspace

FROM base AS withUser

ARG GROUP_ID=1000
ARG USER_ID=1000
ARG USER_NAME=dev
RUN set -x \
  && : "Add user account" \
  && groupadd -g $GROUP_ID $USER_NAME \
  && useradd -m -u $USER_ID -g $USER_NAME $USER_NAME \
  && chsh -s /bin/bash $USER_NAME

USER $USER_NAME
COPY .bashrc /home/${USER_NAME}/.bashrc
COPY .gitconfig /home/${USER_NAME}/.gitconfig
