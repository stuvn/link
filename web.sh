#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

if [ -f /var/lib/dpkg/lock ]; then
  rm -f /var/lib/dpkg/lock
fi

os=$(cat /etc/issue | awk '{print $2}' | cut -c 1-5)

if [[ $os = 16.04 || $os = 18.04 ]]; then
  export LC_ALL=C
fi

echo "setting timezone and crontab ..."
rm -f /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Hong_Kong /etc/localtime
echo '#0  3    * * *   root    /sbin/reboot'>>/etc/crontab
echo "5 5    1 * *   root	systemctl stop nginx && /root/.acme.sh/acme.sh --issue --standalone -d www.${domain} --force && systemctl restart nginx">>/etc/crontab

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
  apt-get update && apt-get install make build-essential wget net-tools curl vim pwgen ntpdate git supervisor -y
  echo ""
  echo "installing supervisor ... "
  echo ""
  apt-get install supervisor pwgen -y
fi

if [[ $os = 20.04 ]]; then
  apt-get update && apt-get install make build-essential wget net-tools curl vim python3-pip python3-wheel python3-setuptools ntpdate git supervisor -y
  echo ""
  echo "installing supervisor ... "
  echo ""
  apt-get install python3-pip python3-wheel python3-setuptools supervisor -y
fi
 

if [ $( date | grep HKT | wc -l ) == 0 ]; then
  cp /usr/share/zoneinfo/Asia/Hong_Kong /etc/localtime
fi

if [ -f /var/lib/dpkg/lock ]; then
  rm -f /var/lib/dpkg/lock
fi

read -p "输入新的mysql root密码:" mpwd

apt-get install redis-server -y

echo "requirepass ${mpwd}">>/etc/redis/redis.conf
echo ""
echo "add program to supervisor"
echo ""

sleep 1
sed -i '/^files =.*/d' /etc/supervisor/supervisord.conf
echo "files = conf.d/*.conf" >> /etc/supervisor/supervisord.conf

cat > /etc/supervisor/conf.d/stype.conf<<-EOF
[program:stype]
command = /root/shadowsocks-manager/bin/ssmgr -c /root/.ssmgr/ss.yml
user = root
autostart = true
autorestart = true
EOF

cat > /etc/supervisor/conf.d/web.conf<<-EOF
[program:web]
command = /root/shadowsocks-manager/bin/ssmgr -c /root/.ssmgr/webgui.yml
user = root
autostart = true
autorestart = true
EOF

echo "add supervisor startup ..."

systemctl enable supervisor

if [ -f /var/lib/dpkg/lock ]; then
  rm -f /var/lib/dpkg/lock
fi

echo "installing ssmgr ..."
curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash - 

if [ -f /var/lib/dpkg/lock ]; then
  rm -f /var/lib/dpkg/lock
fi

apt-get install -y nodejs

git clone https://github.com/stuvn/shadowsocks-manager.git
cd shadowsocks-manager
npm i --unsafe-perm
cd ~
mkdir /root/.ssmgr

echo "create config file for  ssmgr ..."

cat > /root/.ssmgr/ss.yml<<-EOF
type: s

shadowsocks:
  address: 127.0.0.1:7008
manager:
  address: 0.0.0.0:7009
  password: 'tmppasswd'
db: 'ss.sqlite'
EOF

[ $# -gt '1' ] && [ "$1" == '-d' ] && domain="$2" || domain='www.xxx.com'

read -p "输入hi@${domain}邮箱密码:" epwd

cat > /root/.ssmgr/webgui.yml<<-EOF
type: m

manager:
  address: 127.0.0.1:7009
  password: 'tmppasswd'
plugins:
  flowSaver:
    use: true
  user:
    use: true
  account:
    use: true
  macAccount:
    use: false
  group:
    use: true
  email:
    use: true
    type: 'smtp'
    username: 'hi@${domain}'
    password: '${epwd}'
    host: 'smtp.zoho.com'
  webgui:
    use: true
    host: '127.0.0.1'
    port: '8080'
    site: 'https://${domain}'
    icon: 'icon.png'
    skin: 'fs_sample'
    language: 'zh-CN'
    # googleAnalytics: 'UA-xxxxxxxx-x'
    # gcmSenderId: '456102641793'
    # gcmAPIKey: 'AAAAGzzdqrE:XXXXXXXXXXXXXX'
  alipay:
    use: true
    appid: 2018083161190122
    notifyUrl: ''
    merchantPrivateKey: 'MIIEpQIBAAKCAQEA28Ku9k/L/OdYXyJi1hMPb9LM0bysWu1tE6xPqzknDdgLRooAyu3JxVz2RpWquWQorAAL5NwR6gVuKmPxEAi3GU/nmXtyPIuI9uxxzCVjleM7cL+V0O4DUNGdh945DkabkRI/SPQpmwJhD43L/DtNrpAaLN2cRZYYJT0DJea/yTFly7Ae+pAEv1NSKdt9NzcwjTQ+EWD2Tjaea2JlD0PjAsCpFr1uNasDeByryDI+FxZspVWh8y3eyE/Cv8B/oiwP4qwIl2y0cZKlVK3ddBMlM4B3wX7jcZVxateBAFJFQKIOdBLIlH+q90vberawiepQslmEJOzA5fJFb/m6S4pONQIDAQABAoIBAQCFtb+EqGqiFxSi1aYzQGedDzKFznlD3cAHP0k+EckcWD4MDj2LOwEQL468xaWZpUJF3MVf2zKfI+yyqBptOhBFu2Nb9Es+YVvVeWmH35vm/9oTsM3z0E1+J/vkRiaK9BUFQIf22HBUGy95KjpZ3q9WLeFvOOszP66zQZsfvXUlcOMvSnL+odJhCq8hzlEuUzZTtY/Vyi4OYm7fnXEE0x5d7Rev28FPLuB86SPKQ94gjDRAvb6aPY+JtYaVitsJfYU2UjUaOgNjDzBhEsPQQadBpImCJyL6hKw4XJNHcyHhSXdC7r2973+8uITUciaKLeMTDkElQQIN0jwzNk67yYYhAoGBAO48Hm71EbH2IgumC2otYxo/8K5+0kzCaIZpcRdZPC2rylYXn3lcK02ESCcpJp1cLMRVNeE4CiPALZtdYJa0HCUnuSpwKi5u3kgxD6NFrxDKsYyeifXnMqJfDFyJ/lYdvKk2nb4v+tBC7ARGpa3zW3eslm+VUPK9jaouDosfvUJJAoGBAOwl5ArVLV9r5U5EZiFtlLQ+Bf0qyIVYnwUtX06o1gQOSL20aQtfH/bL5LEuKeVboWT/vQrMo73cfUqKRB7A5l5A/zX6HqGiuI2lvtKZi5KZqpEv4fMILS8E9RzZDY4m84qxMQ+GPE9I+/4Gljug1XKSTtS5GBU4+WKG5iUVpmyNAoGBAOkNGLx0sxXDcTSx/3Kj6dGxARLCb5m1iKkMlxw/KDaJWotz2obPGnFfWXItuF+x3v1FWkrzFkA47KSS6T0j/nB+do5EYY9A1+QJUoHnVkX3805bfRx4Sjk7AA261HqL5pYmHpQBvbtj7ByWu9b6PN1KkXOgvypnMiFrosCIkQ05AoGAXAJ7ctkSv64rfy5ZWMb4fK356WWFEaew9fRywRQ5pwTlxLyJfTvIGYHiDkL9Yfcs0ExwnMeVOQGy85sh5ZWlbK4IgkB9NN9Q5yfgTPA0mJ80/TLZ57aU3FAjLOVJSczVcYGOqwzTbNT0EksAuCT3ZZeqDWo8/u/fA0uqWmKwIHUCgYEAndeU1qKYiW+XsjLioAC2EmlpzbJYiMBD0WILsLLWn6AeU1Q5B+kjMWQrMrlif3BIpzWXxBsroDIMqX+bIJhBGzf/alDkBMgCKd3FlXVa1Rqv/CECqiD0V8vSriogHumpixwNTZ06DtpbBH/AUia5+rd7iFKbIOnAfkpqLourvZw='
    alipayPublicKey: 'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEArVVQmMiSNG1+8W7wh8hSOv/jeBaRS+fEiQJRMhyQpP6XhTcw8y03bw4fcuOK2V7+R1j+cdn2QyEk7pBpUXdqarvdCf1PbMKl58biNK3j0br8lwIRVKIuvLqV11UHB8zoV+ZY0bQh/wWDpNcl8JVWtqUOACBXBi7AyhMiXjep3U6ldgrk9SLcepeY6+EzLJw3C6+214cH8WHXTnsEDFa2iMmxNpQBOhVt1CqXW23zhvIJZt+jXhPD3mj9uCX4lXnDMi4cZvPJ7hv/UaqGU1F0SpVdSaCqz04YOSOE1AO+hatNIcB5tHmbGJsITkCB/8+/IknjpkPN/lSQLuPEAo/kCQIDAQAB'
    gatewayUrl: 'https://openapi.alipay.com/gateway.do'
  paypal:
    use: false
    mode: 'live'
    client_id: 'At9xcGd1t5L6OrICKNnp2g9'
    client_secret: 'EP40s6pQAZmqp_G_nrU9kKY4XaZph'
  #webgui_crisp:
    #use: true
    #websiteId: '6d8e3987-ec62-08b2-80a1-b3c776ad371c'

db:
  host: '127.0.0.1'
  user: 'root'
  password: ${mpwd}
  database: 'ssmgr'

redis:
  host: '127.0.0.1'
  port: 6379
  password: 'miaXRvbmt5XzEyOTk'
  db: 0
EOF

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
echo 'net.ipv4.tcp_fin_timeout = 30'>>/etc/sysctl.conf
echo 'net.ipv4.tcp_keepalive_time = 1200'>>/etc/sysctl.conf
echo 'net.ipv4.icmp_echo_ignore_all = 1'>>/etc/sysctl.conf
echo 'net.ipv4.ip_local_port_range = 1025 65000'>>/etc/sysctl.conf
echo 'net.ipv4.tcp_max_syn_backlog = 8192'>>/etc/sysctl.conf
echo 'net.ipv4.tcp_max_tw_buckets = 5000'>>/etc/sysctl.conf
echo 'net.ipv4.tcp_mem = 25600 51200 102400'>>/etc/sysctl.conf
echo 'net.ipv4.tcp_rmem = 4096 87380 67108864'>>/etc/sysctl.conf
echo 'net.ipv4.tcp_wmem = 4096 65536 67108864'>>/etc/sysctl.conf
echo 'vm.swappiness = 20'>>/etc/sysctl.conf
echo 'vm.vfs_cache_pressure = 50'>>/etc/sysctl.conf

echo 'net.core.default_qdisc = fq' >>/etc/sysctl.conf
echo 'net.ipv4.tcp_congestion_control = bbr' >>/etc/sysctl.conf

echo "installing nginx mysql ..."

apt-get install curl gnupg2 ca-certificates lsb-release -y

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

if [[ $os = 20.04 ]]; then
  echo 'deb http://nginx.org/packages/ubuntu/ focal nginx'>>/etc/apt/sources.list
  echo 'deb-src http://nginx.org/packages/ubuntu/ focal nginx'>>/etc/apt/sources.list
fi

apt-get update

if [ -f /var/lib/dpkg/lock ]; then
  rm -f /var/lib/dpkg/lock
fi

apt-get install socat mysql-server mysql-client nginx -y

echo "create database..."

if [[ $os = 16.04  || $os = 18.04 ]]; then
  echo 'sql_mode = STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION'>>/etc/mysql/mysql.conf.d/mysqld.cnf
  echo ""
  echo "cancel mysql bind-address ..."
  echo ""
  sed -i 's/^bind-address/#bind-address/' /etc/mysql/mysql.conf.d/mysqld.cnf
fi

if [[ $os = 20.04 ]]; then
  echo 'skip-log-bin'>>/etc/mysql/mysql.conf.d/mysqld.cnf
  echo 'sql_mode = STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION'>>/etc/mysql/mysql.conf.d/mysqld.cnf
  echo ""
  echo "cancel mysql bind-address ..."
  echo ""
  sed -i 's/^bind-address/#bind-address/' /etc/mysql/mysql.conf.d/mysqld.cnf
  sed -i 's/^mysqlx-bind-address/#mysqlx-bind-address/' /etc/mysql/mysql.conf.d/mysqld.cnf
fi

create_db_sql="CREATE DATABASE IF NOT EXISTS ssmgr DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci"

update_user_sql="update mysql.user set host = '%' where user = 'root'"

if [[ $os = 16.04 ]]; then
  mysql -uroot -p${mpwd} -e "${create_db_sql}"
fi

if [[ $os = 18.04 || $os = 20.04 ]]; then
  mysql -uroot -p -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '"${mpwd}"'"
  sleep 3
  mysql -uroot -p${mpwd} -e "${create_db_sql}"
fi

sleep 1
mysql -uroot -p${mpwd} -e "${update_user_sql}"

service mysql restart

cd ~ && sleep 3
if [ -e /root/ssmgr.sql ]; then
  mysql -uroot -p${mpwd} ssmgr < /root/ssmgr.sql
fi

cat > /etc/nginx/conf.d/ss.conf<<-EOF
server {
  listen         80;
  server_name    ${domain} www.${domain};
  return   301   https://${domain}\$request_uri;
}

server {
  listen       443 ssl http2;
  server_name  www.${domain};

  ssl_certificate /root/.acme.sh/www.${domain}_ecc/fullchain.cer;
  ssl_certificate_key /root/.acme.sh/www.${domain}_ecc/www.${domain}.key;
        
  return  301  https://${domain}\$request_uri;
}

server {  
  listen                 443 ssl http2;
  server_name            ${domain};

  ##
  # SSL Settings
  ##

  ssl_protocols TLSv1.2 TLSv1.3;
  ssl_prefer_server_ciphers on;
  
  ssl_ciphers 'ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA:ECDHE-ECDSA-DES-CBC3-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:DES-CBC3-SHA:!DSS';
  ssl_ecdh_curve secp384r1; # Requires nginx >= 1.1.0
  ssl_session_cache shared:SSL:10m;
  ssl_session_tickets off; # Requires nginx >= 1.5.9
  ssl_stapling on; # Requires nginx >= 1.3.7
  ssl_stapling_verify on; # Requires nginx => 1.3.7
  resolver 8.8.8.8 8.8.4.4 valid=300s;
  resolver_timeout 5s;
  add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload";
  add_header X-Frame-Options DENY;
  add_header X-Content-Type-Options nosniff;
                
  fastcgi_intercept_errors on;

  ssl_certificate        /root/.acme.sh/${domain}_ecc/fullchain.cer;
  ssl_certificate_key    /root/.acme.sh/${domain}_ecc/${domain}.key;

  location / {
      if (\$request_filename ~* ^.*?\.(dmg|exe|zip|gz|doc|pdf)$) {
	add_header  Content-Disposition attachment;
	add_header  Content-Type application/octet-stream;
      }

      proxy_set_header   X-Real-IP \$remote_addr;
      proxy_set_header   Host      \$http_host;
      proxy_pass         http://127.0.0.1:8080;
  }
}
EOF

sed -i 's/#gzip  on;/gzip  on;/g' /etc/nginx/nginx.conf
sed -i 's/net.ipv4.conf.eth1.rp_filter=0/#net.ipv4.conf.eth1.rp_filter=0/g' /etc/sysctl.conf

if [ -f /var/lib/dpkg/lock ]; then
  rm -f /var/lib/dpkg/lock
fi

apt-get install socat && curl -L get.acme.sh | bash -

systemctl stop nginx 

/root/.acme.sh/acme.sh --set-default-ca  --server  zerossl
/root/.acme.sh/acme.sh  --register-account  -m hi@${domain} --server zerossl

/root/.acme.sh/acme.sh --issue --standalone -d ${domain}
sleep 10
/root/.acme.sh/acme.sh --issue --standalone -d www.${domain}

systemctl start nginx

systemctl restart ssh

/root/.acme.sh/acme.sh --upgrade --auto-upgrade 

echo "supervisord -c /etc/supervisord.conf"

echo > /var/log/wtmp
echo > /var/log/btmp
echo > /var/log/lastlog
  
cd ~ && rm -f nginx_signing.key web.sh && ifconfig && sysctl -p && date
history -c && history -w
