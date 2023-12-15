#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

read -p "输入新的root密码:" rpwd

echo root:${rpwd}| chpasswd

echo "setting timezone and crontab ..."
rm -f /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Hong_Kong /etc/localtime

if [ -f /var/lib/dpkg/lock ]; then
  rm -f /var/lib/dpkg/lock
fi

if [ "$(cat /proc/meminfo|grep SwapTotal|awk '{print $2}')" -le "500000" ];then  
  echo " create swap file ..."
  dd if=/dev/zero of=/var/swapfile bs=1M count=1001 && mkswap -f /var/swapfile && chmod 600 /var/swapfile 
  swapon /var/swapfile && echo '/var/swapfile   swap   swap defaults 0 0'>>/etc/fstab 
fi

while getopts "p:" opt
do
    case $opt in
        p)
	port="$OPTARG"
        ;;
        ?)
        echo "unknow arg"
        exit 1;;
    esac
done

pwd=$(date +%N)

card=$(ls /sys/class/net|grep en|awk 'NR==1{print}')

if [ ${port} -lt 1025 -a  ${port} -gt 65535 ]; then
  echo "unknow arg, the arg should be 1025-65535"
  exit 1
fi

echo "setting ssh port@65001"

if [ -s /etc/ssh/sshd_config ] && grep 'Port 22' /etc/ssh/sshd_config; then
  sed -i 's/#Port 22/Port 22/g' /etc/ssh/sshd_config
  sed -i 's/Port 22/Port 65001/g' /etc/ssh/sshd_config
  systemctl reload sshd
fi
echo "setting ulimit n@65535 ..."

if [ ! -f "/etc/rc.local" ]; then 
  echo '#!/bin/bash'>>/etc/rc.local
  chmod a+x /etc/rc.local
fi

echo 'ulimit -n 65535'>>/etc/profile

echo "installing tools ..."
apt-get update && apt-get install wget net-tools python-pip python-dev python-wheel python-setuptools curl vim -y

echo ""
echo "installing supervisor ..."
echo ""

if [ -f /var/lib/dpkg/lock ]; then
  rm -f /var/lib/dpkg/lock
fi

pip install supervisor && echo_supervisord_conf > /etc/supervisord.conf
echo '[include]'>>/etc/supervisord.conf
echo 'files = /etc/supervisor.d/*.conf'>>/etc/supervisord.conf

mkdir -p /etc/supervisor.d 

echo "installing wireguard ... "

apt-get update

sudo add-apt-repository ppa:wireguard/wireguard
sudo apt update
sudo apt install wireguard -y

iptables -t filter -A FORWARD -i wg0 -j ACCEPT
iptables -t filter -A FORWARD -o wg0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i wg0 -o ${card} -j ACCEPT
iptables -A FORWARD -i ${card} -o wg0 -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -t nat -A POSTROUTING -o ${card} -j MASQUERADE

echo 1 >/proc/sys/net/ipv4/ip_forward

cd ~
wg genkey > privatekey
wg pubkey < privatekey > publickey

private=$(cat privatekey)
public=$(cat publickey)

cat > /root/wg0.conf<<-EOF
[Interface]
Address = 10.100.0.1/16 
PrivateKey = ${private} 
ListenPort = ${port}
EOF

wg-quick up ./wg0.conf
echo 'wg-quick up ./wg0.conf'>>/etc/rc.local

systemctl enable wg-quick@wg0 

echo "add supervisor startup ..."
if grep '^exit 0' /etc/rc.local;then
  sed -i '/^exit 0/i\/usr/local/bin/supervisord -c /etc/supervisord.conf' /etc/rc.local
fi

if ! grep '^exit 0' /etc/rc.local;then
  echo '/usr/local/bin/supervisord -c /etc/supervisord.conf'>>/etc/rc.local
fi

curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash - 

apt-get install -y nodejs 

git clone https://github.com/gyteng/shadowsocks-manager-wireguard.git

cd shadowsocks-manager-wireguard && npm i

cat > /etc/supervisor.d/wireguard.conf<<-EOF
[program:wireguard]
command = node /root/shadowsocks-manager-wireguard/index.js --gateway 10.100.0.1 --manager 0.0.0.0:7009 --password ${pwd} --interface wg0
user = root
autostart = true
autorestart = true
EOF

echo "setting sysctl ..."
echo '* soft nofile 65535'>>/etc/security/limits.conf
echo '* hard nofile 65535'>>/etc/security/limits.conf

echo 'fs.file-max = 65535'>>/etc/sysctl.conf

echo 'net.core.rmem_max = 67108864'>>/etc/sysctl.conf
echo 'net.core.wmem_max = 67108864'>>/etc/sysctl.conf
echo 'net.core.netdev_max_backlog = 250000'>>/etc/sysctl.conf
echo 'net.core.somaxconn = 4096'>>/etc/sysctl.conf

echo 'net.ipv4.tcp_syncookies = 1'>>/etc/sysctl.conf
echo 'net.ipv4.tcp_tw_reuse = 1'>>/etc/sysctl.conf
echo '#net.ipv4.tcp_tw_recycle = 0'>>/etc/sysctl.conf
echo 'net.ipv4.icmp_echo_ignore_all = 1'>>/etc/sysctl.conf
echo 'net.ipv4.tcp_fin_timeout = 30'>>/etc/sysctl.conf
echo 'net.ipv4.tcp_keepalive_time = 1200'>>/etc/sysctl.conf
echo 'net.ipv4.ip_local_port_range = 1025 65535'>>/etc/sysctl.conf
echo 'net.ipv4.tcp_max_syn_backlog = 8192'>>/etc/sysctl.conf
echo 'net.ipv4.tcp_max_tw_buckets = 5000'>>/etc/sysctl.conf
echo 'net.ipv4.tcp_fastopen = 3'>>/etc/sysctl.conf
echo 'net.ipv4.tcp_mem = 25600 51200 102400'>>/etc/sysctl.conf
echo 'net.ipv4.tcp_rmem = 4096 87380 67108864'>>/etc/sysctl.conf
echo 'net.ipv4.tcp_wmem = 4096 65536 67108864'>>/etc/sysctl.conf
echo 'net.ipv4.tcp_mtu_probing = 1'>>/etc/sysctl.conf
echo 'net.ipv4.tcp_congestion_control = htcp'>>/etc/sysctl.conf
if [ $( ps -fe | grep aliyun-service | grep -v grep | wc -l ) == 1 ]; then
  echo "remove aliyun-service ..."
  wget http://update.aegis.aliyun.com/download/uninstall.sh && chmod +x uninstall.sh && bash uninstall.sh
  wget http://update.aegis.aliyun.com/download/quartz_uninstall.sh && chmod +x quartz_uninstall.sh && bash quartz_uninstall.sh
  pkill aliyun-service && rm -rf /etc/init.d/agentwatch /usr/sbin/aliyun-service && rm -rf /usr/local/aegis*
fi

if [ -f /var/lib/dpkg/lock ]; then
  rm -f /var/lib/dpkg/lock
fi

/usr/local/bin/supervisord -c /etc/supervisord.conf

echo "installing nginx ..."

apt-get install nginx -y && cd /etc/nginx/conf.d/ && wget --no-check-certificate 'https://raw.githubusercontent.com/stuvn/link/master/www.conf'
cd /usr/share/nginx/html && rm -rf * && wget --no-check-certificate 'https://raw.githubusercontent.com/stuvn/link/master/404.html'
cp 404.html index.html
sed -i 's/include \/etc\/nginx\/sites-enabled\/\*;/#include \/etc\/nginx\/sites-enabled\/\*;/g' /etc/nginx/nginx.conf

systemctl restart nginx

echo "installing bbr ..."

ifconfig && cd ~

echo "Wgport: ${port}"
echo "Passwd: ${pwd}"
echo "Public: ${public}"
echo "Interface: ${card}"
