#!/usr/bin bash

cd ~
wget -O clash.tar.gz 'https://github.com/stuvn/link/releases/download/v0.20.21/clash.tar.gz'
sleep 1
tar zxvf clash.tar.gz
chmod +x ~/clash/cfw
chmod +x ~/clash/resources/static/files/linux/x64/clash-linux
echo 'export http_proxy=http://127.0.0.1:7890'>> ~/.profile
echo 'export https_proxy=http://127.0.0.1:7890'>> ~/.profile
source ~/.profile
rm -f ~/clash.sh ~/clash.tar.gz
~/clash/cfw