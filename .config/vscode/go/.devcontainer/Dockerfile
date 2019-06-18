FROM golang:1.12.6-stretch AS build

RUN set -x && go get -u -v github.com/acroca/go-symbols 2>&1
RUN set -x && go get -u -v github.com/alecthomas/gometalinter 2>&1
RUN set -x && go get -u -v github.com/derekparker/delve/cmd/dlv 2>&1
RUN set -x && go get -u -v github.com/golang/dep/cmd/dep 2>&1
RUN set -x && go get -u -v github.com/golangci/golangci-lint/cmd/golangci-lint 2>&1
RUN set -x && go get -u -v github.com/mdempsky/gocode 2>&1
RUN set -x && go get -u -v github.com/mgechev/revive 2>&1
RUN set -x && go get -u -v github.com/ramya-rao-a/go-outline 2>&1
RUN set -x && go get -u -v github.com/rogpeppe/godef 2>&1
RUN set -x && go get -u -v github.com/sqs/goreturns 2>&1
RUN set -x && go get -u -v github.com/uudashr/gopkgs/cmd/gopkgs 2>&1
RUN set -x && go get -u -v golang.org/x/lint/golint 2>&1
RUN set -x && go get -u -v golang.org/x/tools/cmd/goimports 2>&1
RUN set -x && go get -u -v golang.org/x/tools/cmd/gorename 2>&1
RUN set -x && go get -u -v golang.org/x/tools/cmd/guru 2>&1
RUN set -x && go get -u -v github.com/zmb3/gogetdoc 2>&1
RUN set -x && go get -u -v honnef.co/go/tools/... 2>&1
RUN set -x \
  && go get -x -d github.com/stamblerre/gocode \
  && go build -o gocode-gomod github.com/stamblerre/gocode \
  && mv gocode-gomod $GOPATH/bin/

FROM golang:1.12.6-stretch AS base

COPY --from=build $GOPATH/bin/* /usr/local/bin/

RUN set -x \
  && : "Install git, process tools, lsb-release (common in install instructions for CLIs)" \
  && apt-get update \
  && apt-get -y install \
    git \
    lsb-release \
    procps \
  && apt-get autoremove -y \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/*

# Set the default shell to bash instead of sh
ENV SHELL /bin/bash
