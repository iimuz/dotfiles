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

RUN set -x \
  && : "Install tools for vscode" \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    curl \
    git \
    lsb-release \
    procps \
    wget \
  && chsh -s /bin/bash \
  && : "Clean" \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN set -x \
  && : "Install c++" \
  && apt-get update \
  && apt-get install -y \
    build-essential \
    cmake \
    cppcheck \
    ctags \
    global \
    valgrind \
  && apt-get autoremove -y \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/*

RUN set -x \
  && : "Install markdown setting" \
  && apt-get update \
  && : "install google chrome." \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    gpg-agent \
    unzip \
  && : "wget --no-check-certificate https://dl-ssl.google.com/linux/linux_signing_key.pub" \
  && wget https://dl-ssl.google.com/linux/linux_signing_key.pub \
  && cat linux_signing_key.pub | apt-key add \
  && rm linux_signing_key.pub \
  && echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | tee /etc/apt/sources.list.d/google-chrome.list \
  && apt-get update \
  && apt-get install -y google-chrome-stable \
  && : "install puppeteer for converting pdf." \
  && apt-get install -y nodejs npm \
  && npm install -g puppeteer \
  && apt-get install -y --no-install-recommends fonts-noto-cjk \
  && fc-cache -fv \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
COPY style.less /root/.mume/style.less

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
  && unlink /usr/bin/python \
  && ln -s python3.7 /usr/bin/python \
  && : "Install pipenv" \
  && pip3 install pipenv \
  && : "Install pip tools for vscode" \
  && pip3 install -r requirements.txt \
  && rm requirements.txt* \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN set -x \
  && : "Install R" \
  && apt-get update \
  && apt-get install -y --no-install-recommends r-base \
  && : "Install renv" \
  && R -e "install.packages('remotes', repos = c(CRAN = 'https://cloud.r-project.org'))" \
  && R -e "remotes::install_github('rstudio/renv')" \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN set -x \
  && : "Install other development tools" \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    gpg \
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
RUN set -x \
  && : "Add user account" \
  && groupadd -g $GROUP_ID $USER_NAME \
  && useradd -m -u $USER_ID -g $USER_NAME $USER_NAME \
  && chsh -s /bin/bash $USER_NAME

USER dev
ENV DEBIAN_FRONTEND=dialog \
  HOME=/home/$USER_NAME
COPY .bashrc $HOME/.bashrc
COPY .gitconfig $HOME/.gitconfig
COPY style.less $HOME/.mume/style.less

