FROM ubuntu:18.04 AS base
LABEL maintainer iimuz

ENV DEBIAN_FRONTEND=noninteractive
RUN set -x \
  && : "Configure apt" \
  && apt-get update \
  && apt-get install -y --no-install-recommends apt-utils 2>&1 \
  && apt-get autoremove -y \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/*

RUN set -x \
  && : "Install git, process tools, lsb-release (common in install instructions for CLIs)" \
  && apt-get install -y \
    git \
    lsb-release \
    procps \
  && apt-get autoremove -y \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/*

ENV DEBIAN_FRONTEND=dialog
ENV SHELL /bin/bash
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
