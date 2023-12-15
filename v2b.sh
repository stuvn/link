#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

if [ -f /var/lib/dpkg/lock ]; then
  rm -f /var/lib/dpkg/lock
fi

os=$(cat /etc/issue | awk '{print $2}' | cut -c 1-5)
read -p "输入根域名(不带www):" domain

echo ""
echo "setting timezone and crontab ..."
echo ""
rm -f /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Hong_Kong /etc/localtime

apt update && apt install cron socat -y

echo "*  *    * * *   root    php /home/wwwroot/artisan schedule:run" >>/etc/crontab
echo "#" >>/etc/crontab

read -p "输入新的root密码:" rpwd

echo root:${rpwd} | chpasswd

if [ "$(cat /proc/meminfo|grep SwapTotal|awk '{print $2}')" -le "500000" ];then  
  echo " create swap file ..."
  dd if=/dev/zero of=/var/swapfile bs=1M count=1001 && mkswap -f /var/swapfile && chmod 600 /var/swapfile 
  swapon /var/swapfile && echo '/var/swapfile   swap   swap defaults 0 0'>>/etc/fstab 
fi

apt-get update 

echo "setting ssh port@9999"

if [ ! -f "/etc/rc.local" ]; then 
  echo '#!/bin/bash'>>/etc/rc.local
  chmod a+x /etc/rc.local
fi

sed -i "s/^Port.*/Port 9999/g" /etc/ssh/sshd_config

if [ -s /etc/ssh/sshd_config ] && grep 'Port 22' /etc/ssh/sshd_config; then
  sed -i 's/#Port 22/Port 22/g' /etc/ssh/sshd_config
  sed -i 's/Port 22/Port 9999/g' /etc/ssh/sshd_config 
fi

if [ -f /var/lib/dpkg/lock ]; then
  rm -f /var/lib/dpkg/lock
fi

echo "installing tools ..."

if [[ $os = 18.04 || $os = 16.04 ]]; then
     export LC_ALL=C
fi

apt-get update && apt-get install wget net-tools curl vim supervisor pwgen ntpdate git -y

if [ -f /var/lib/dpkg/lock ]; then
  rm -f /var/lib/dpkg/lock
fi

echo ""
echo "add program to supervisor"
echo ""

sleep 1
sed -i '/^files =.*/d' /etc/supervisor/supervisord.conf
echo "files = conf.d/*.conf" >> /etc/supervisor/supervisord.conf

cat > /etc/supervisor/conf.d/v2b.conf<<-EOF
[program:V2board]
directory = /home/wwwroot
command = php artisan horizon
user = www-data
autostart = true
autorestart = true
EOF

systemctl enable supervisor

if [ -f /var/lib/dpkg/lock ]; then
  rm -f /var/lib/dpkg/lock
fi

echo ""
echo "install mysql-server and redis-server..."
echo ""

read -p "输入新的mysql root密码:" mpwd

apt-get install  mysql-server redis-server -y

echo "requirepass ${mpwd}">>/etc/redis/redis.conf
echo ""
echo "create database..."
echo ""

create_db_sql="CREATE DATABASE IF NOT EXISTS v2b DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"

if [[ $os = 16.04  || $os = 18.04 ]]; then
  echo 'sql_mode = STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION'>>/etc/mysql/mysql.conf.d/mysqld.cnf
fi

if [[ $os = 20.04 ]]; then
  echo 'skip-log-bin'>>/etc/mysql/mysql.conf.d/mysqld.cnf
  echo 'sql_mode = STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION'>>/etc/mysql/mysql.conf.d/mysqld.cnf
fi

if [[ $os = 16.04 ]]; then
  mysql -uroot -p${mpwd} -e "${create_db_sql}"
fi

if [[ $os = 18.04 || $os = 20.04 ]]; then
  mysql -uroot -p -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '"${mpwd}"'"
  sleep 3
  mysql -uroot -p${mpwd} -e "${create_db_sql}"
fi

echo ""
echo "installing v2board ..."
echo ""

if [ -f /var/lib/dpkg/lock ]; then
  rm -f /var/lib/dpkg/lock
fi

mkdir -p /home/wwwroot/
apt install git nginx php-fpm php-mbstring php-mysql php-redis php-gd php-pear php-zip php-bcmath php-curl php-xml php-xmlrpc -y
cd /home/wwwroot/
sleep 1
git clone https://github.com/stuvn/v2board.git ./
sleep 1
sed -i "s/REDIS_PASSWORD=null/REDIS_PASSWORD=${mpwd}/g" /home/wwwroot/.env.example
sleep 1
sh init.sh
sleep 1
cd ~
chmod -R 755 /home/wwwroot/
chown -R www-data:www-data /home/wwwroot/

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
echo 'net.core.default_qdisc = fq' >>/etc/sysctl.conf
echo 'net.ipv4.tcp_congestion_control = bbr' >>/etc/sysctl.conf

apt-get update

if [ -f /var/lib/dpkg/lock ]; then
  rm -f /var/lib/dpkg/lock
fi

cat > /etc/nginx/conf.d/v2b.conf<<-EOF
server {
    listen       80;
    server_name  ${domain} www.${domain};
    return 301 https://${domain}\$request_uri;
}

server {
    listen       443 ssl http2;
    server_name  www.${domain};

    ssl_certificate /root/.acme.sh/www.${domain}_ecc/fullchain.cer;
    ssl_certificate_key /root/.acme.sh/www.${domain}_ecc/www.${domain}.key;
        
    return 301 https://${domain}\$request_uri;
}

server {
    listen       443 ssl http2;
    server_name  ${domain};
    root   /home/wwwroot/public;
    index  index.php index.html;

    ssl_certificate /root/.acme.sh/${domain}_ecc/fullchain.cer;
    ssl_certificate_key /root/.acme.sh/${domain}_ecc/${domain}.key;

    #charset koi8-r; 
    #access_log  /var/log/nginx/host.access.log  main;

    location /download {
    }

    location / {
        try_files \$uri \$uri/ /index.php\$is_args\$query_string;
    }

    location ~ .*\.(gif|jpg|jpeg|png|bmp|swf)$ {
        expires 1d;
    }

    location ~ .*\.(js|css)?$ {
        expires 1h;
        error_log off;
        access_log /dev/null;
    }

    error_page  404              /404.html;

    # redirect server error pages to the static page /50x.html
    #
    error_page   500 502 503 504  /50x.html; 
    location = /50x.html {
        root   /home/wwwroot/public;
    }

    # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
    #
    location ~ \.php$ {
        root           /home/wwwroot/public;
        fastcgi_pass   unix:/run/php/php7.4-fpm.sock;

	#fastcgi_split_path_info ^(.+?\.php)(/.*)$;
	try_files \$fastcgi_script_name =404; 

        fastcgi_index  index.php; 
        fastcgi_param  SCRIPT_FILENAME  \$document_root\$fastcgi_script_name;
        include        fastcgi_params;
    }
}
EOF

sed -i 's/#gzip  on;/gzip  on;/g' /etc/nginx/nginx.conf
sed -i 's/access_log/#access_log/g' /etc/nginx/nginx.conf

php_conf=$(find / -name php.ini | grep fpm)

sed -i 's/putenv,p/p/' $php_conf
sed -i 's/pcntl_alarm,p/p/' $php_conf
sed -i 's/pcntl_signal,p/p/' $php_conf
sed -i 's/proc_open,p/p/' $php_conf

if [ -f /var/lib/dpkg/lock ]; then
  rm -f /var/lib/dpkg/lock
fi

apt-get install socat && curl -L get.acme.sh | bash -

systemctl stop nginx 

/root/.acme.sh/acme.sh --set-default-ca  --server  zerossl
/root/.acme.sh/acme.sh  --register-account  -m hi@berk.top --server zerossl
/root/.acme.sh/acme.sh --issue --standalone -d ${domain}

systemctl start nginx

systemctl restart ssh

systemctl restart supervisor

/root/.acme.sh/acme.sh --upgrade --auto-upgrade 

wget https://raw.githubusercontent.com/stuvn/link/master/down.sh
chmod +x down.sh

echo > /var/log/wtmp
echo > /var/log/btmp
echo > /var/log/lastlog
  
cd ~ && rm -f v2b.sh && ifconfig | grep inet && sysctl -p && date
history -c && history -w
