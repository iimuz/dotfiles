# update
sudo apt -y update
sudo apt -y upgrade

# install basic apps
sudo apt install -y --no-install-recommends ca-certificates curl make wget

# install japanese
sudo apt install -y --no-install-recommends task-japanese
sudo sed -i 's/# ja_JP.UTF-8/ja_JP.UTF-8/' /etc/locale.gen
sudo locale-gen
sudo update-locale LANG=ja_JP.UTF-8

# bash settings
echo "\nif [ -f ~/.bashrc.local ]; then\n  . ~/.bashrc.local\nfi\n" >> ~/.bashrc
wget https://raw.githubusercontent.com/iimuz/dotfiles/master/.bashrc -O ~/.bashrc.local

# install docker
sudo apt install -y \
  apt-transport-https \
  gnupg2 \
  software-properties-common
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
sudo apt update
sudo apt install -y --no-install-recommends docker-ce
sudo curl -L https://github.com/docker/compose/releases/download/1.21.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

sudo mkdir /c
mount --bind /mnt/c /c
echo "export DOCKER_HOST='tcp://0.0.0.0:2375'" >> ~/.bashrc.local

# install git
sudo apt install -y --no-install-recommends git less ssh
wget https://raw.githubusercontent.com/iimuz/dotfiles/master/.gitconfig -O ~/.gitconfig

# install ghq
sudo apt install -y --no-install-recommends unzip
wget https://github.com/motemen/ghq/releases/download/v0.8.0/ghq_linux_amd64.zip
unzip ghq_linux_amd64.zip -d ghq
sudo mv ghq/ghq /usr/bin/
rm -rf ghq ghq_linux_amd64.zip .wget-hsts
echo "[ghq]\n  root = ~/src\n" >> ~/.gitconfig.local

# install fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
yes | ~/.fzf/install

# install neovim
sudo apt install -y --no-install-recommends neovim
mkdir -p ~/.config/nvim
wget https://raw.githubusercontent.com/iimuz/dotfiles/master/.vimrc -O ~/.config/nvim/init.vim

# install tmux
sudo apt install -y --no-install-recommends tmux
wget https://raw.githubusercontent.com/iimuz/dotfiles/master/.tmux.conf -O ~/.tmux.conf

rm -rf .wget-hsts
