#!/bin/bash

export PATH="/usr/bin:/usr/local/bin:$PATH"

read -p "请输入ss://协议的链接: " input

# 提取ss://之后的字符串
encoded_data=$(echo "$input" | sed -n 's|^ss://\([^@]*\).*|\1|p')

# 解码base64
decoded_data=$(echo "$encoded_data" | base64 -d)

# 提取加密方式和密码
IFS=':' read -r encryption password <<< "$decoded_data"

# 提取服务器地址和端口
server_and_port=$(echo "$input" | sed -n 's|^ss://[^@]*@\([^/?]*\).*|\1|p')
IFS=':' read -r server port <<< "$server_and_port"

# 输出结果
echo "加密方式: $encryption"
echo "密码: $password"
echo "服务器地址: $server"
echo "端口: $port"

# 构建simple-obfs插件参数
opts='--plugin obfs-local --plugin-opts obfs=http;obfs-host=www.apple.com'

# 构建Shadowsocks客户端连接命令
ss_command="ss-local -s $server -p $port -k $password -m $encryption -l 1080 $opts"

# 输出命令
echo "连接命令: $ss_command"
echo "正在连接: $server ..."
sleep 1
$ss_command
