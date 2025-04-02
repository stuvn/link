#!/bin/bash

CONFIG_FILE="/etc/systemd/resolved.conf"
DNS_SETTING="DNS=8.8.8.8"

# 检查文件中是否已存在 DNS 设置
if grep -q "^DNS=" "$CONFIG_FILE"; then
    # 提取当前的 DNS 值
    CURRENT_DNS=$(grep "^DNS=" "$CONFIG_FILE" | awk -F= '{print $2}')
    if [ "$CURRENT_DNS" == "8.8.8.8" ]; then
        echo "DNS 已设置为 8.8.8.8，无需更改。"
        exit 0
    else
        echo "当前 DNS 设置为 $CURRENT_DNS，修改为 8.8.8.8。"
        sudo sed -i "s/^DNS=.*/$DNS_SETTING/" "$CONFIG_FILE"
    fi
else
    echo "未找到 DNS 设置，添加 DNS=8.8.8.8。"
    sudo sed -i "/^\[Resolve\]/a $DNS_SETTING" "$CONFIG_FILE"
fi

# 重启 systemd-resolved 服务以应用更改
sudo systemctl restart systemd-resolved

echo "DNS 设置已更新并应用。"
