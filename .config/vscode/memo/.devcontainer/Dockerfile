FROM python:3.7.3-stretch AS base
LABEL maintainer "iimuz"

ENV DEBIAN_FRONTEND=noninteractive
COPY requirements.txt /
RUN set -x \
  && : "Install tools for vscode" \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    git \
    procps \
  && apt-get install -y libicu[0-9][0-9] \
  && pip install -r /requirements.txt \
  && rm /requirements.txt \
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
  && hugoWorkdir=/opt/hugo \
  && mkdir -p $hugoWorkdir \
  && cd $hugoWorkdir \
  && wget https://github.com/gohugoio/hugo/releases/download/v${hugoVersion}/${hugoArchive} \
  && tar -xvzf $hugoArchive \
  && mv hugo /usr/local/bin/ \
  && cd / \
  && rm -rf $hugoWorkdir \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN set -x \
  && : "Install other development tools" \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    gpg \
    make \
  && git --version \
  && wget https://raw.githubusercontent.com/git/git/v2.22.0/contrib/credential/netrc/git-credential-netrc -O /usr/share/doc/git/contrib/credential/netrc/git-credential-netrc \
  && chmod +x /usr/share/doc/git/contrib/credential/netrc/git-credential-netrc \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
COPY .bashrc /root/.bashrc
COPY .gitconfig /root/.gitconfig

RUN set -x \
  && : "Install for vscode packages" \
  && apt-get update \
  && : "Install packages for markdown to pdf" \
  && apt-get install -y --no-install-recommends libxtst6 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

ENV DEBIAN_FRONTEND=dialog \
  SHELL=/bin/bash \
  HOME=/root
WORKDIR /workspace
CMD ["sleep", "infinity"]

FROM base AS withUser
LABEL maintainer "iimuz"

ENV DEBIAN_FRONTEND=noninteractive

ARG GROUP_ID=1000
ARG USER_ID=1000
ARG USER_NAME=dev
RUN set -x \
  && : "Add user" \
  && useradd -u $USER_ID -g $USER_NAME $USER_NAME \
  && groupadd -g $GROUP_ID $USER_NAME

USER $USER_NAME
COPY .bashrc /home/$USER_NAME/.bashrc
COPY .gitconfig /home/$USER_NAME/.gitconfig
ENV DEBIAN_FRONTEND=dialog \
  HOME=/home/$USER_NAME
