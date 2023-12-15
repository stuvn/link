#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

function rand(){
    min=$1
    max=$(($2-$min+1))
    num=$(date +%s%N)
    echo $(($num%$max+$min))
}

red='\033[31m'
green='\033[32m'
cclear='\033[0m'

echo "请输入混淆类型(默认http)"
echo "1 : tls"
echo "2 : http"
echo "3 : none"
echo -n "请输入数字:"
read -e obfs
echo ""

if [ "$obfs" = "" ]; then
    obfs=2
fi

if [ $obfs != "1" ] && [ $obfs != "2" ] && [ $obfs != "3" ]; then
    echo "输入错误，已退出 | Input error, exit"
    exit;
fi

if [ $obfs == '1' ]; then
    echo -e "${green}选择混淆:tls${cclear} \n"
    obfs="tls"
    plugin=' --plugin obfs-server --plugin-opts obfs=tls;failover=127.0.0.1:80'
elif [ $obfs == '2' ]; then
    echo -e "${green}选择混淆:http${cclear} \n"
    obfs="http"
    plugin=' --plugin obfs-server --plugin-opts obfs=http;failover=127.0.0.1:80'
else
    echo -e "${green}纯ss,无混淆${cclear} \n"
    obfs="none"
    plugin=''
fi

rnd=$(rand 10 59)
method='chacha20-ietf-poly1305'
os=$(cat /etc/issue | awk '{print $2}' | cut -c 1-5)

echo "setting timezone and crontab ..."
rm -f /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Hong_Kong /etc/localtime

path_0=$(which echo)
path_1=$(which pgrep)
path_2=$(which reboot)
path_3=$(which systemctl)

echo "${rnd} 2 * * 1  root  ${path_0} >/var/www/html/log.txt ; ${path_2}">>/etc/crontab
echo "#" >>/etc/crontab 
echo "${rnd} 3 * * *  root  pid=\$(${path_1} node) ; ${path_3} restart supervisor ; ${path_0} \`date\` restart pid=\$pid>>/var/www/html/log.txt">>/etc/crontab
echo "#" >>/etc/crontab 
systemctl restart cron

if [ -f /var/lib/dpkg/lock ]; then
  rm -f /var/lib/dpkg/lock
fi

if [ "$(cat /proc/meminfo|grep SwapTotal|awk '{print $2}')" -le "500000" ];then  
  echo " create swap file ..."
  dd if=/dev/zero of=/var/swapfile bs=1M count=1001 && chmod 600 /var/swapfile && mkswap -f /var/swapfile
  swapon /var/swapfile && echo '/var/swapfile   swap   swap defaults 0 0'>>/etc/fstab 
fi

if [ $( ufw status | grep 'Status: active' | wc -l ) == 1 ]; then
  ufw disable 
  systemctl disable ufw
fi

echo "setting ssh port@8888"

if [ ! -f "/etc/rc.local" ]; then 
  echo '#!/bin/bash'>>/etc/rc.local
  chmod a+x /etc/rc.local
fi

sed -i "s/^Port.*/Port 8888/g" /etc/ssh/sshd_config

if [ -s /etc/ssh/sshd_config ] && grep 'Port 22' /etc/ssh/sshd_config; then
  sed -i 's/#Port 22/Port 22/g' /etc/ssh/sshd_config
  sed -i 's/Port 22/Port 8888/g' /etc/ssh/sshd_config
fi

echo "setting ulimit n@65535 ..."
ulimit -n 65535
echo 'ulimit -n 65535'>>/etc/profile

echo ""
echo -e "${green}installing supervisor ... ${cclear}"
echo ""

apt-get update && apt-get install cron wget net-tools curl vim supervisor pwgen unzip -y
sleep 1
sed -i '/^files =.*/d' /etc/supervisor/supervisord.conf
echo "files = conf.d/*.conf" >> /etc/supervisor/supervisord.conf

pwd=$(pwgen -s 15 1)
sleep 1
echo root:Rt_${pwd} | chpasswd
sleep 1
pwd=Nd_${pwd}

if [[ $os = 16.04 || $os = 18.04 ]]; then 
  export LC_ALL=C
  echo ""
  echo "installing shadowsocks ... " 
  echo ""
  apt-get update
  apt-get install --no-install-recommends gettext build-essential autoconf git libtool libpcre3-dev asciidoc xmlto libev-dev libc-ares-dev automake libmbedtls-dev libsodium-dev pkg-config -y
  cd /usr/local/src
  git clone https://github.com/shadowsocks/shadowsocks-libev.git
  cd /usr/local/src/shadowsocks-libev
  git submodule update --init --recursive
  sh autogen.sh
  ./configure --disable-documentation
  make && make install && cd ~

  ln -s /usr/local/bin/ss-manager /usr/bin/ss-manager
  ln -s /usr/local/bin/ss-server /usr/bin/ss-server

  echo ""
  echo "installing simple-obfs ... " 
  echo ""
  sleep 3
  apt-get update
  apt-get install --no-install-recommends build-essential autoconf libtool libssl-dev libpcre3-dev libev-dev asciidoc xmlto automake pwgen -y
  git clone https://github.com/shadowsocks/simple-obfs.git
  cd simple-obfs
  git submodule update --init --recursive
  ./autogen.sh
  ./configure 
  make && make install && cd ~
    ln -s /usr/local/bin/obfs-server /usr/bin/obfs-server
fi

if [ $os = 20.04 ]; then
echo ""
echo -e "${green}installing shadowsocks and simple-obfs... ${cclear}" 
echo ""

apt-get update
apt-get install shadowsocks-libev simple-obfs -y
fi

cat > /etc/supervisor/conf.d/shadowsocks.conf<<-EOF
[program:shadowsocks]
command = /usr/bin/ss-manager -u -m ${method} --manager-address 127.0.0.1:8886${plugin}
user = root
autostart = true
autorestart = true
EOF

cat > /etc/supervisor/conf.d/stype.conf<<-EOF
[program:stype]
command = node /root/.ssmgr/index.js -s 127.0.0.1:8886 -m 0.0.0.0:8887 -p ${pwd} -d /root/.ssmgr/data.json
user = root
autostart = true
autorestart = true
EOF

echo ""
echo -e "${green}installing ssmgr... ${cclear}"
echo ""
sleep 1
apt-get update
apt-get install ca-certificates
sleep 1
curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash - 
sleep 1
apt-get install -y nodejs 
cd ~ && wget https://codeload.github.com/gyteng/shadowsocks-manager-tiny/zip/refs/heads/master && unzip master
mv shadowsocks-manager-tiny-master .ssmgr && rm -f master  

echo ""
echo -e "create config file for ssmgr ... "
echo ""
cat > /root/.ssmgr/ss.yml<<-EOF
type: s

shadowsocks:
  address: 127.0.0.1:8886
manager:
  address: 0.0.0.0:8887
  password: '${pwd}'
db: 'ss.sqlite'
EOF

echo '* soft nofile 512000'>>/etc/security/limits.conf
echo '* hard nofile 512000'>>/etc/security/limits.conf

echo > /etc/sysctl.conf
echo 'fs.file-max = 512000'>>/etc/sysctl.conf
echo 'net.core.rmem_max = 67108864'>>/etc/sysctl.conf
echo 'net.core.wmem_max = 67108864'>>/etc/sysctl.conf
echo 'net.core.somaxconn = 4096'>>/etc/sysctl.conf
echo 'net.ipv4.tcp_tw_reuse = 1'>>/etc/sysctl.conf
echo 'net.ipv4.icmp_echo_ignore_all = 1'>>/etc/sysctl.conf
echo 'net.ipv4.tcp_fastopen = 0'>>/etc/sysctl.conf
echo 'net.ipv4.tcp_syncookies = 1'>>/etc/sysctl.conf
echo '#net.ipv4.tcp_tw_recycle = 0'>>/etc/sysctl.conf
echo 'net.ipv4.tcp_fin_timeout = 30'>>/etc/sysctl.conf
echo 'net.ipv4.tcp_keepalive_time = 1200'>>/etc/sysctl.conf
echo 'net.core.netdev_max_backlog = 250000'>>/etc/sysctl.conf
echo 'net.ipv4.ip_local_port_range = 1025 65535'>>/etc/sysctl.conf
echo 'net.ipv4.tcp_max_syn_backlog = 8192'>>/etc/sysctl.conf
echo 'net.ipv4.tcp_max_tw_buckets = 5000'>>/etc/sysctl.conf
echo 'net.ipv4.tcp_mem = 25600 51200 102400'>>/etc/sysctl.conf
echo 'net.ipv4.tcp_rmem = 4096 87380 67108864'>>/etc/sysctl.conf
echo 'net.ipv4.tcp_wmem = 4096 65536 67108864'>>/etc/sysctl.conf
echo 'vm.swappiness = 20'>>/etc/sysctl.conf
echo 'vm.vfs_cache_pressure = 50'>>/etc/sysctl.conf
echo 'net.ipv4.tcp_mtu_probing = 1'>>/etc/sysctl.conf

echo 'net.core.default_qdisc = fq'>>/etc/sysctl.conf
echo 'net.ipv4.tcp_congestion_control = bbr'>>/etc/sysctl.conf

if [ $( ps -fe | grep AliYunDunUpdate | grep -v grep | wc -l ) == 1 ]; then
  echo "remove aliyun-service ..."
  service aegis stop
  wget http://update.aegis.aliyun.com/download/uninstall.sh && chmod +x uninstall.sh && bash uninstall.sh
  wget http://update.aegis.aliyun.com/download/quartz_uninstall.sh && chmod +x quartz_uninstall.sh && bash quartz_uninstall.sh
  pkill aliyun-service && rm -rf /etc/init.d/agentwatch /usr/sbin/aliyun-service /usr/local/share/aliyun-assist && rm -rf /usr/local/aegis* && rm /lib/systemd/system/aliyun.service
  rm -rf /usr/local/aegis/aegis_update/
  rm -rf /usr/local/aegis/aegis_client/
  rm -f /usr/local/aegis/PythonLoader/AliSecureCheckAdvanced
  iptables -I INPUT -s 140.205.201.0/28 -j DROP
  iptables -I INPUT -s 140.205.201.16/29 -j DROP
  iptables -I INPUT -s 140.205.201.32/28 -j DROP
  iptables -I INPUT -s 140.205.225.192/29 -j DROP
  iptables -I INPUT -s 140.205.225.200/30 -j DROP
  iptables -I INPUT -s 140.205.225.184/29 -j DROP
  iptables -I INPUT -s 140.205.225.183/32 -j DROP
  iptables -I INPUT -s 140.205.225.206/32 -j DROP
  iptables -I INPUT -s 140.205.225.205/32 -j DROP
  iptables -I INPUT -s 140.205.225.195/32 -j DROP
  iptables -I INPUT -s 140.205.225.204/32 -j DROP
  service iptables save
  echo ""
fi

if [ -f /var/lib/dpkg/lock ]; then
  rm -f /var/lib/dpkg/lock
fi

echo -e "${green}installing nginx... ${cclear}"
echo ""

apt-get install nginx -y
sleep 2

sed -i 's/http:\/\/nginx\.com\//\.\/log\.txt/' /var/www/html/index.nginx-debian.html

systemctl reload sshd
systemctl restart nginx

systemctl stop shadowsocks-libev && systemctl disable shadowsocks-libev
rm -rf /etc/shadowsocks-libev/*
sysctl -p | grep fq
sysctl -p | grep bbr

cd ~ && rm -rf ss.sh && ifconfig | grep inet

echo > /var/log/wtmp
echo > /var/log/btmp
echo > /var/log/lastlog

echo -e "${green}OS Ver: $os ${cclear}\n${red}Method: $method ${cclear} \n${green}Passwd: $pwd ${cclear}"
history -c && history -w
sleep 2
result=$(cat /etc/supervisor/conf.d/shadowsocks.conf | grep $obfs)
if [[ "$result" != "" ]]; then
    echo -e "${red}simple-obfs=${obfs} ${cclear}"
else 
    echo -e "${red}simlpe-obfs=none ${cclear}"
fi
date
systemctl restart supervisor
