#!/bin/bash
#
# nvidia driver をインストールします。
# 設定完了後にリブートをした方が良いです。

# nouveau ドライバーの無効化
lsmod | grep nouveau
sudo sh -c "cat <<EOF>> /etc/modprobe.d/blacklist-nouveau.conf
blacklist nouveau
options nouveau modeset=0
EOF"
update-initramfs -u

# nvidia driver のインストール
lspci | grep VGA
sudo -E apt install -y --no-install-recommends nvidia-driver-390
nvidia-smi

