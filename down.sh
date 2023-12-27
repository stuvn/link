#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

echo "remove windows old apps"

rm -f /home/wwwroot/public/images/win/win.zip
rm -f /home/wwwroot/public/images/win/clash.exe
rm -f /home/wwwroot/public/images/win/v2rayN.zip

echo "downloading windows apps"

wget https://github.com/stuvn/link/releases/download/v0.20.21/win.zip
wget https://github.com/stuvn/link/releases/download/v0.20.21/clash.exe
wget https://github.com/stuvn/link/releases/download/v0.20.21/v2rayN.zip

echo "download finish ..."

mv win.zip /home/wwwroot/public/images/win/win.zip
mv clash.exe /home/wwwroot/public/images/win/clash.exe
mv v2rayN.zip /home/wwwroot/public/images/win/v2rayN.zip

echo "remove macos old apps"

rm -f /home/wwwroot/public/images/mac/ClashX.dmg
rm -f /home/wwwroot/public/images/mac/ShadowsocksX-NG.dmg

echo "downloading macos apps"

wget https://github.com/stuvn/link/releases/download/v0.20.21/ClashX.dmg
wget https://github.com/stuvn/link/releases/download/v0.20.21/ShadowsocksX-NG.dmg

echo "download finish ..."

mv ClashX.dmg /home/wwwroot/public/images/mac/ClashX.dmg
mv ShadowsocksX-NG.dmg /home/wwwroot/public/images/mac/ShadowsocksX-NG.dmg

echo "remove linux old apps"

rm -f /home/wwwroot/public/images/linux/clash.tar.gz

echo "downloading linux apps"

wget https://github.com/stuvn/link/releases/download/v0.20.21/clash.tar.gz

echo "download finish ..."

mv clash.tar.gz /home/wwwroot/public/images/linux/clash.tar.gz

echo "remove android old apps"

rm -f /home/wwwroot/public/images/android/cfa.apk
rm -f /home/wwwroot/public/images/android/sfb.apk

echo "downloading android apps"

wget https://github.com/stuvn/link/releases/download/v0.20.21/cfa.apk
wget https://github.com/stuvn/link/releases/download/v0.20.21/sfb.apk

echo "download finish ..."

mv cfa.apk /home/wwwroot/public/images/android/cfa.apk
mv sfb.apk /home/wwwroot/public/images/android/sfb.apk


