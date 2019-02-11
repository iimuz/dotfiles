alias glist='gcloud compute instances list'
alias gscp='gcloud compute scp'
alias gssh='gcloud compute ssh'
alias gstart='gcloud compute instances start'
alias gstop='gcloud compute instances stop'

# comand using docker
alias dgconfig='docker run -it --name gcloud-config -e USER_ID=$(id -u) -e GROUP_ID=$(id -g) localhost:gcloud bash'
alias dgcloud='docker run --rm -it --volumes-from gcloud-config -v $(pwd):/src -e USER_ID=$(id -u) -e GROUP_ID=$(id -g) localhost:gcloud gcloud'
alias dglist='dgcloud compute instances list'
alias dgscp='dgcloud compute scp'
alias dgssh='dgcloud compute ssh'
alias dgstart='dgcloud compute instances start'
alias dgstop='dgcloud compute instances stop'

