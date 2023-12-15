#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

if [ -f /var/lib/dpkg/lock ]; then
  rm -f /var/lib/dpkg/lock
fi

apt install curl git gnupg2 ca-certificates lsb-release -y

if [ -f /var/lib/dpkg/lock ]; then
  rm -f /var/lib/dpkg/lock
fi

os=$(cat /etc/issue | awk '{print $2}' | cut -c 1-5)

echo "setting timezone and crontab ..."
rm -f /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Hong_Kong /etc/localtime
echo '#0  3    * * *   root    /sbin/reboot'>>/etc/crontab

read -p "请输入root新密码：" pwd

echo root:${pwd} | chpasswd

if [ "$(cat /proc/meminfo|grep SwapTotal|awk '{print $2}')" -le "500000" ];then  
  echo " create swap file ..."
  dd if=/dev/zero of=/var/swapfile bs=1M count=1001 && mkswap -f /var/swapfile && chmod 600 /var/swapfile 
  swapon /var/swapfile && echo '/var/swapfile   swap   swap defaults 0 0'>>/etc/fstab 
fi

apt-get update 
echo "setting ssh port@65001"
if [ -s /etc/ssh/sshd_config ] && grep 'Port 22' /etc/ssh/sshd_config; then
  sed -i 's/#Port 22/Port 22/g' /etc/ssh/sshd_config
  sed -i 's/Port 22/Port 65001/g' /etc/ssh/sshd_config 
fi

if [ -f /var/lib/dpkg/lock ]; then
  rm -f /var/lib/dpkg/lock
fi

echo "installing tools ..."
apt-get install wget net-tools curl ntpdate vim -y 

if [ $( date | grep HKT | wc -l ) == 0 ]; then
  cp /usr/share/zoneinfo/Asia/Hong_Kong /etc/localtime
fi

if [ -f /var/lib/dpkg/lock ]; then
  rm -f /var/lib/dpkg/lock
fi

echo "setting ulimit n@65535 ..."

echo 'ulimit -n 65535'>>/etc/profile
echo '* soft nofile 65535'>>/etc/security/limits.conf
echo '* hard nofile 65535'>>/etc/security/limits.conf

if [ $(sysctl -p | grep bbr | wc -l)  == 1 ]; then
  sed -i '/net.core.default_qdisc.*/d' /etc/sysctl.conf
  sed -i '/net.ipv4.tcp_congestion_control.*/d' /etc/sysctl.conf
fi

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
echo 'net.ipv4.ip_local_port_range = 1025 65000'>>/etc/sysctl.conf
echo 'net.ipv4.tcp_max_syn_backlog = 8192'>>/etc/sysctl.conf
echo 'net.ipv4.tcp_max_tw_buckets = 5000'>>/etc/sysctl.conf
echo 'net.ipv4.tcp_fastopen = 3'>>/etc/sysctl.conf
echo 'net.ipv4.tcp_mem = 25600 51200 102400'>>/etc/sysctl.conf
echo 'net.ipv4.tcp_rmem = 4096 87380 67108864'>>/etc/sysctl.conf
echo 'net.ipv4.tcp_wmem = 4096 65536 67108864'>>/etc/sysctl.conf
echo 'net.core.default_qdisc = fq' >>/etc/sysctl.conf
echo 'net.ipv4.tcp_congestion_control = bbr' >>/etc/sysctl.conf

echo "installing nginx mysql ..."

wget http://nginx.org/keys/nginx_signing.key
sudo apt-key add nginx_signing.key

if [[ $os = 16.04 ]]; then
  echo 'deb http://nginx.org/packages/ubuntu/ xenial nginx'>>/etc/apt/sources.list
  echo 'deb-src http://nginx.org/packages/ubuntu/ xenial nginx'>>/etc/apt/sources.list
fi

if [[ $os = 18.04 ]]; then
  echo 'deb http://nginx.org/packages/ubuntu/ bionic nginx'>>/etc/apt/sources.list
  echo 'deb-src http://nginx.org/packages/ubuntu/ bionic nginx'>>/etc/apt/sources.list
fi

apt-get update

if [ -f /var/lib/dpkg/lock ]; then
  rm -f /var/lib/dpkg/lock
fi

apt install socat mysql-server mysql-client nginx -y

echo "installing php-7.4 ..."

apt-get update
apt install lsb-release ca-certificates apt-transport-https software-properties-common
add-apt-repository ppa:ondrej/php
apt install -y php8.0-fpm php8.0-mysql php8.0-curl php8.0-gd php8.0-mbstring php8.0-xml php8.0-xmlrpc php8.0-opcache php8.0-zip php8.0 php8.0-json php8.0-bz2 php8.0-bcmath

[ $# -gt '1' ] && [ "$1" == '-d' ] && domain="$2" || domain='www.xxx.com'

mkdir -p /home/wwwroot/sspanel
cd /home/wwwroot/sspanel

git clone -b 2022.9 --depth 1 https://github.com/Anankke/SSPanel-Uim.git tmp && mv tmp/.git . && rm -rf tmp && git reset --hard
git config core.filemode false
wget https://getcomposer.org/installer -O composer.phar
php composer.phar
php composer.phar install
cd ../
chmod -R 755 sspanel/
chown -R nginx:nginx sspanel/

cd /etc/nginx/conf.d && rm -rf * cd ~

cat > /etc/nginx/conf.d/sspanel.conf<<-EOF
server {
    listen       80;
    server_name  www.${domain} ${domain};
    rewrite ^ https://\$server_name\$request_uri? permanent;
}

server {
    listen       443 ssl http2;
    server_name  www.${domain};
    root   /home/wwwroot/sspanel/public;
    index  index.php index.html;

    ssl_certificate /root/.acme.sh/www.${domain}_ecc/fullchain.cer;
    ssl_certificate_key /root/.acme.sh/www.${domain}_ecc/www.${domain}.key;

    #charset koi8-r;
    #access_log  /var/log/nginx/host.access.log  main;


    location / {
        try_files \$uri /index.php\$is_args\$args;
    }

    location ~ .*\.(gif|jpg|jpeg|png|bmp|swf)$ {
        expires 1d;
    }

    location ~ .*\.(js|css)?$ {
        expires 1h;
    }

    error_page  404              /404.html;

    # redirect server error pages to the static page /50x.html
    #
    error_page   500 502 503 504  /50x.html; 
    location = /50x.html {
        root   /home/wwwroot/sspanel/public;
    }

    # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
    #
    location ~ \.php$ {
        root           /home/wwwroot/sspanel/public;
        fastcgi_pass   unix:/run/php/php8.0-fpm.sock;

	#fastcgi_split_path_info ^(.+?\.php)(/.*)$;
	try_files \$fastcgi_script_name =404; 

        fastcgi_index  index.php; 
        fastcgi_param  SCRIPT_FILENAME  \$document_root\$fastcgi_script_name;
        include        fastcgi_params;
    }
}
EOF

sed -i 's/#gzip  on;/gzip  on;/g' /etc/nginx/nginx.conf
sed -i 's/net.ipv4.conf.eth1.rp_filter=0/#net.ipv4.conf.eth1.rp_filter=0/g' /etc/sysctl.conf

echo "install  and create database..."

create_db_sql="CREATE DATABASE IF NOT EXISTS sspanel DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci"

update_user_sql="update mysql.user set host = '%' where user = 'root'"

read -p "请输入mysql root新密码：" mypwd

if [[ $os = 16.04 ]]; then
  mysql -uroot -p${mypwd} -e "${create_db_sql}"
fi

if [[ $os = 18.04 || $os = 20.04 ]]; then
  mysql -uroot -p -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${mypwd}'"
  sleep 3
  mysql -uroot -p${mypwd} -e "${create_db_sql}"
fi

sleep 1
mysql -uroot -p${mypwd} -e "${update_user_sql}"

service mysql restart

cd ~ && sleep 3
if [ -e /home/wwwroot/sspanel/sql/glzjin_all.sql ]; then
  mysql -uroot -p${mypwd} sspanel < /home/wwwroot/sspanel/sql/glzjin_all.sql
fi

if [ -f /var/lib/dpkg/lock ]; then
  rm -f /var/lib/dpkg/lock
fi

sed -i 's/bind-address/#bind-address/g' /etc/mysql/mysql.conf.d/mysqld.cnf

apt install socat && curl -L get.acme.sh | bash -

systemctl stop nginx && /root/.acme.sh/acme.sh --issue --standalone -d ${domain}

systemctl start nginx

systemctl restart ssh

cd /home/wwwroot/sspanel/
cp config/.config.example.php config/.config.php 

echo " "
echo "Setting Website..."
echo " "

read -p "请输入网站名称：" name

sed -i "s/'1145141919810';/'1145141919x810';/" /home/wwwroot/sspanel/config/.config.php 
sed -i "s/\['appName'\] = 'sspanel';/\['appName'\] = '$name';/" /home/wwwroot/sspanel/config/.config.php 
sed -i "s/'http:\/\/url.com';/'https:\/\/www.${domain}';/" /home/wwwroot/sspanel/config/.config.php 
sed -i "s/'NimaQu';/'${mypwd}';/" /home/wwwroot/sspanel/config/.config.php
sed -i "s/\['db_password'\] = 'sspanel';/\['db_password'\] = 'myiaXRvbmt5XzEyOTk';/" /home/wwwroot/sspanel/config/.config.php

echo " "
echo "Setting Shadowssocks(R)..."
echo " "

sed -i "s/\['reg_protocol'\]='origin';/\['reg_protocol'\]='auth_aes128_sha1';/" /home/wwwroot/sspanel/config/.config.php 
sed -i "s/\['reg_obfs'\]='plain';/\['reg_obfs'\]='tls1.2_ticket_auth';/" /home/wwwroot/sspanel/config/.config.php 

echo " "
echo "Setting PHP..."
echo " "

sed -i 's/user = www-data/user = nginx/g' /etc/php/8.0/fpm/pool.d/www.conf
sed -i 's/group = www-data/group = nginx/g' /etc/php/8.0/fpm/pool.d/www.conf
sed -i 's/listen.owner = www-data/listen.owner = nginx/g' /etc/php/8.0/fpm/pool.d/www.conf
sed -i 's/listen.group = www-data/listen.group = nginx/g' /etc/php/8.0/fpm/pool.d/www.conf

systemctl restart nginx
systemctl restart php8.0-fpm
systemctl restart mysql

php xcat createAdmin
php xcat syncusers
php xcat initQQWry
php xcat resetTraffic
php xcat initdownload

echo "finish!"
