FROM jupyter/base-notebook:latest AS base
LABEL maintainer "iimuz"

USER root

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

COPY requirements.txt /
RUN set -x \
  && : "Install tools for vscode" \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    git \
    procps \
  && apt-get install -y libicu[0-9][0-9] \
  && conda install --file /requirements.txt \
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
    gpg-agent \
    less \
    make \
  && git --version \
  && wget https://raw.githubusercontent.com/git/git/v2.22.0/contrib/credential/netrc/git-credential-netrc -O /usr/share/doc/git/contrib/credential/netrc/git-credential-netrc \
  && chmod +x /usr/share/doc/git/contrib/credential/netrc/git-credential-netrc \
  && chsh -s /bin/bash root \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
RUN set -x \
  && : "install packages for markdown preview enhanced." \
  && apt-get update \
  && : "install google chrome." \
  && apt-get install -y --no-install-recommends \
    curl \
    gpg-agent \
    unzip \
  && wget --no-check-certificate https://dl-ssl.google.com/linux/linux_signing_key.pub \
  && cat linux_signing_key.pub | apt-key add \
  && rm linux_signing_key.pub \
  && echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | tee /etc/apt/sources.list.d/google-chrome.list \
  && apt-get update \
  && apt-get install -y --no-install-recommends google-chrome-stable \
  && : "install puppeteer for converting pdf." \
  && apt-get install -y --no-install-recommends \
    nodejs \
    npm \
  && npm install -g puppeteer \
  && apt-get install -y --no-install-recommends fonts-noto-cjk \
  && fc-cache -fv \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY .bashrc /root/.bashrc
COPY .gitconfig /root/.gitconfig
COPY style.less /root/.mume/style.less
USER jovyan
WORKDIR /workspace
CMD ["sleep", "infinity"]

FROM base AS withUser
LABEL maintainer "iimuz"

USER root

ARG USER_ID=1000
ARG GROUP_ID=1000
RUN set -x \
  && : "Change user id" \
  && groupadd -g $GROUP_ID $NB_USER \
  && usermod -u $USER_ID -g $NB_USER $NB_USER

USER $NB_USER
ENV CONDA_DIR=/opt/conda
ENV PATH=$CONDA_DIR/bin:$PATH
COPY .bashrc /home/${NB_USER}/.bashrc
COPY .gitconfig /home/${NB_USER}/.gitconfig
COPY style.less /home/${NB_USER}/.mume/style.less
