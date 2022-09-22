#!/bin/sh
#
# Install jq

set -eu

wget -q https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
mv jq-linux64 jq
chmod +x jq
mv jq $HOME/.local/bin/

echo "complete: jq"
