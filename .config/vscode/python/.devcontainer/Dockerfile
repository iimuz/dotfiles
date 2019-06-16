FROM python:3.7.3-stretch AS base
LABEL maintainer "iimuz"

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

COPY .devcontainer/requirements.txt /
RUN set -x && \
  : "Install pip tools for vscode" && \
  pip install -r requirements.txt && \
  rm requirements.txt*

COPY requirements.txt /
RUN set -x && \
  : "Install pip tools for project" && \
  pip install -r requirements.txt && \
  rm requirements.txt*

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
