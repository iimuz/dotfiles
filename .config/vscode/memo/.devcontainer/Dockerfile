FROM jupyter/scipy-notebook:latest AS base
LABEL maintainer "iimuz"

USER root

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
  && git --version \
  && wget https://github.com/git/git/blob/v2.22.0/contrib/credential/netrc/git-credential-netrc -O /usr/share/doc/git/contrib/credential/netrc/git-credential-netrc \
  && chmod +x /usr/share/doc/git/contrib/credential/netrc/git-credential-netrc \
  && chsh -s /bin/bash root \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
COPY .bashrc /root/.bashrc
COPY .gitconfig /root/.gitconfig

RUN set -x \
  && : "Install packages for markdown to pdf" \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    libxtst6 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

USER jovyan
COPY jupyter_notebook_config.py /home/jovyan/.jupyter/jupyter_notebook_config.py
WORKDIR /home/jovyan/work

FROM base AS withUser

USER root

ARG GROUP_ID=1000
ARG USER_ID=1000
RUN set -x \
  && : "Change user id" \
  && groupadd -g $GROUP_ID $NB_USER \
  && usermod -u $USER_ID -g $NB_USER $NB_USER

USER $NB_USER
ENV CONDA_DIR=/opt/conda
ENV PATH=$CONDA_DIR/bin:$PATH
COPY .bashrc /home/${NB_USER}/.bashrc
COPY .gitconfig /home/${NB_USER}/.gitconfig
