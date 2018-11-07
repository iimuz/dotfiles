#!/bin/sh
#
# Install gcloud

BASHRC_MAIN=~/.bashrc
BASHRC_DIR=~/.config/gcloud
BASHRC_GCLOUD=$BASHRC_DIR/bashrc

# curl https://sdk.cloud.google.com | bash

cat <<EOF >> $BASHRC_MAIN

# The next line enables shell alias command using gcloud.
if [ -f '${BASHRC_GCLOUD}' ]; then . '${BASHRC_GCLOUD}'; fi
EOF

mkdir -p $BASHRC_DIR
cat <<EOF >> $BASHRC_GCLOUD
alias glist='gcloud compute instances list'
alias gstart='gcloud compute instances start'
alias gstop='gcloud compute instances stop'
alias gssh='gcloud compute ssh'
EOF

. $BASHRC_MAIN

