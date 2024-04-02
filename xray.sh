#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

function rand(){
    min=$1
    max=$(($2-$min+1))
    num=$(date +%s%N)
    echo $(($num%$max+$min))
}

apt install cron -y

red='\033[31m'
green='\033[32m'
cclear='\033[0m'

echo "请输入节点类型(默认shadowsocks)"
echo "1 : shadowsocks"
echo "2 : trojan"
echo -n "请输入数字:"
read -e type
echo ""

if [ "$type" = "" ]; then
    type=1
fi

if [ $type != "1" ] && [ $type != "2" ]; then
    echo "输入错误，已退出 | Input error, exit"
    exit;
fi

if [ $type == '1' ]; then
    echo -e "${green}选择: shadowsocks ${cclear} \n"
    type="Shadowsocks"
else
    echo -e "${green}选择: trojan ${cclear} \n"
    type="Trojan"
fi

echo -n "请输入ApiHost(主站URL):"
read -e apihost
echo ""

echo -n "请输入节点的ID:"
read -e nodeid
echo ""

echo -n "请输入节点通信密钥:"
read -e key
echo ""
apikey=${key}

rnd=$(rand 10 59)
os=$(cat /etc/issue | awk '{print $2}' | cut -c 1-5)

echo "setting timezone and crontab ..."
rm -f /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Hong_Kong /etc/localtime

path_0=$(which echo)
path_1=$(which pgrep)
path_2=$(which reboot)
path_3=$(which systemctl)

echo "${rnd} 2 * * 1  root  ${path_0} \`date\` Restart >>/var/www/html/log.txt ; ${path_2}">>/etc/crontab
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

apt-get update && apt-get install net-tools curl supervisor pwgen unzip -y
sleep 1
sed -i '/^files =.*/d' /etc/supervisor/supervisord.conf
echo "files = conf.d/*.conf" >> /etc/supervisor/supervisord.conf

pwd=$(pwgen -s 15 1)
sleep 1
echo root:Rt_${pwd} | chpasswd
sleep 1


if [ -f /var/lib/dpkg/lock ]; then
  rm -f /var/lib/dpkg/lock
fi

echo ""
echo -e "${green}installing nginx... ${cclear}"
echo ""

apt-get install nginx -y
sleep 1

echo ""
echo -e "${green}installing xrayr... ${cclear}"
echo ""

install_XrayR() {

    mkdir /usr/local/XrayR/ -p
    cd /usr/local/XrayR/

    last_version=$(curl -Ls "https://api.github.com/repos/XrayR-project/XrayR/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    echo -e "检测到 XrayR 最新版本：${last_version}，开始安装v0.9.0\n"
    wget -q -N --no-check-certificate -O /usr/local/XrayR/XrayR-linux.zip https://github.com/XrayR-project/XrayR/releases/download/v0.9.0/XrayR-linux-64.zip
    sleep 5
    if [ ! -f "XrayR-linux-64.zip" ]; then
        wget -q -N --no-check-certificate -O /usr/local/XrayR/XrayR-linux.zip https://github.com/stuvn/link/releases/download/v0.20.21/XrayR-linux-64.zip
    fi
    unzip XrayR-linux.zip
    rm XrayR-linux.zip -f
    chmod +x XrayR
    mkdir /etc/XrayR/ -p
    rm /etc/systemd/system/XrayR.service -f
    file="https://raw.githubusercontent.com/stuvn/link/master/XrayR.service"
    wget -q -N --no-check-certificate -O /etc/systemd/system/XrayR.service ${file}
    systemctl daemon-reload
    systemctl stop XrayR
    systemctl enable XrayR
    echo -e "\nXrayR v0.9.0 安装完成，已设置开机自启"
    cp geoip.dat /etc/XrayR/
    cp geosite.dat /etc/XrayR/ 
    cp config.yml /etc/XrayR/

    if [[ ! -f /etc/XrayR/dns.json ]]; then
        cp dns.json /etc/XrayR/
    fi
    if [[ ! -f /etc/XrayR/route.json ]]; then
        cp route.json /etc/XrayR/
    fi
    if [[ ! -f /etc/XrayR/custom_outbound.json ]]; then
        cp custom_outbound.json /etc/XrayR/
    fi
    if [[ ! -f /etc/XrayR/custom_inbound.json ]]; then
        cp custom_inbound.json /etc/XrayR/
    fi
    if [[ ! -f /etc/XrayR/rulelist ]]; then
        cp rulelist /etc/XrayR/
    fi

    curl -o /usr/bin/XrayR -Ls https://raw.githubusercontent.com/stuvn/link/master/XrayR.sh
    chmod +x /usr/bin/XrayR
    ln -s /usr/bin/XrayR /usr/bin/xrayr # 小写兼容
    chmod +x /usr/bin/xrayr
    cd ~
}

install_XrayR

echo ""

if [ $type == 'Shadowsocks' ]; then
    echo -e "${green}配置: shadowsocks 节点${cclear} \n"  
    sleep 2
else
    echo -e "${green}配置: trojan 节点${cclear} \n"
    rm /etc/nginx/nginx.conf -f
    wget -q -N --no-check-certificate -O /etc/nginx/nginx.conf https://raw.githubusercontent.com/stuvn/link/master/nginx.conf
    sed -i 's/ListenIP: 0.0.0.0/ListenIP: 127.0.0.1/' /etc/XrayR/config.yml
    sed -i 's/EnableProxyProtocol: false/EnableProxyProtocol: true/' /etc/XrayR/config.yml
    sed -i 's/EnableFallback: false/EnableFallback: true/' /etc/XrayR/config.yml
    echo ""
    read -p "输入连接端口:" port
    echo ""
    read -p "输入节点域名:" domain
    echo ""
    sleep 1
    sed -i "s/443/${port}/g" /etc/nginx/nginx.conf
    sleep 1
    sed -i "s%xxx.com.cer;%/root/.acme.sh/${domain}_ecc/fullchain.cer;%" /etc/nginx/nginx.conf
    sleep 1
    sed -i "s%xxx.com.key;%/root/.acme.sh/${domain}_ecc/${domain}.key;%" /etc/nginx/nginx.conf
    sleep 1
    apt-get install socat && curl -L get.acme.sh | bash -
    systemctl stop nginx 
    /root/.acme.sh/acme.sh --set-default-ca  --server  letsencrypt
    /root/.acme.sh/acme.sh --issue --standalone -d $domain
    nginx -t
fi

sed -i 's/SSpanel/NewV2board/' /etc/XrayR/config.yml
sleep 1
sed -i "s%http:\/\/127.0.0.1:667%${apihost}%" /etc/XrayR/config.yml
sleep 1
sed -i "s/123/${apikey}/" /etc/XrayR/config.yml
sleep 1
sed -i "s/NodeID: 41/NodeID: ${nodeid}/" /etc/XrayR/config.yml
sleep 1
sed -i "s/NodeType: V2ray/NodeType: ${type}/" /etc/XrayR/config.yml
sleep 1
sed -i 's/CertMode: dns/CertMode: none/' /etc/XrayR/config.yml
sleep 1

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

sed -i 's/http:\/\/nginx\.com\//\.\/log\.txt/' /var/www/html/index.nginx-debian.html

systemctl reload sshd
systemctl restart nginx
systemctl disable ufw 

sysctl -p | grep fq
sysctl -p | grep bbr

cd ~ && rm -rf ss.sh && ifconfig | grep inet

echo > /var/log/wtmp
echo > /var/log/btmp
echo > /var/log/lastlog

echo -e "${green}OS Ver: $os ${cclear}\n${red}Type: $type ${cclear}\n${green}seckey: ${apikey} ${cclear}"
history -c && history -w
echo -e "{red}`date`${cclear}\n"
systemctl restart XrayR
nginx -t
systemctl restart nginx
curl https://raw.githubusercontent.com/zhanghanyun/backtrace/main/install.sh -sSf | sh
