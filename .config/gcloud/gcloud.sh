#!/bin/bash
#
# Setting for gcloud command.

# Gurad if command does not exist.
if ! type gcloud > /dev/null 2>&1; then return 0; fi

# Load gcloud setting file.
path_bash="$HOME/google-cloud-sdk/path.bash.inc"
if [ -f "$path_bash" ]; then source "$path_bash"; fi

completion_bash="$HOME/google-cloud-sdk/completion.bash.inc"
if [ -f "$completion_bash" ]; then source "$completion_bash"; fi

# Aliases.
alias gcdel='gcloud compute instances delete'
alias gclist='gcloud compute instances list'
alias gconf_proj='gcloud config set project'
alias gcscp='gcloud compute scp'
alias gcssh='gcloud compute ssh'
alias gcstart='gcloud compute instances start'
alias gcstop='gcloud compute instances stop'

