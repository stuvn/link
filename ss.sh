#!/bin/bash

# 1. 提示用户输入ss://协议的链接
read -p "请输入ss://链接: " ss_link

# 2. 截取输入字符串中"?"前面的字符并输出结果
parsed_link=$(echo $ss_link | cut -d'?' -f1)

# 3. 对结果字符"ss://"和"@"字符之间的字符串进行base64解码并输出结果
decoded_string=$(echo $parsed_link | awk -F'ss://' '{print $2}' | awk -F'@' '{print $1}' | base64 -d -)

# 4. 对上一步结果的字符串以":"字符分割为两个变量依次是加密方式和密码，并输出各自变量
IFS=':' read -r encryption_method password <<< "$decoded_string"
echo "加密方式: $encryption_method"
echo "密码: $password"

# 5. 对截取后字符串"@"字符后面及"/"字符面前的字符串以":"字符分割为两个变量，依次是服务器地址和端口，并输出各自变量
server_info=$(echo $parsed_link | awk -F'@' '{print $2}' | awk -F'/' '{print $1}')
IFS=':' read -r server_address server_port <<< "$server_info"
echo "服务器地址: $server_address"
echo "端口: $server_port"

# 6. 构建ss-local连接命令字符串，包括obfs-local插件和本地监听端口
obfs_opts="obfs=http;obfs-host=www.apple.com"
ss_local_command="ss-local -s $server_address -p $server_port -l 1080 -k $password -m $encryption_method --plugin obfs-local --plugin-opts $obfs_opts"
echo "连接命令: $ss_local_command"
echo "正在连接: $server_address ..."
$ss_local_command
