#!/usr/bin/env bash
# ==========================================
# XrayR Shadowsocks 一键部署脚本
# Debian12 / Ubuntu20+
# ==========================================

set -e

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

echo "更新系统并安装依赖..."
apt update && apt install -y curl unzip openssl ufw chrony

# ===============================
# 时间同步
# ===============================
systemctl enable chrony
systemctl restart chrony
chronyc makestep
timedatectl set-timezone UTC

# ===============================
# OS 检测
# ===============================
. /etc/os-release
echo "系统: $NAME $VERSION_ID"

if [[ "$NAME" != *"Ubuntu"* && "$NAME" != *"Debian"* ]]; then
    echo "❌ 不支持系统"
    exit 1
fi

# ===============================
# 安装 XrayR（稳定版）
# ===============================
XRAYR_VERSION="v0.9.0"
INSTALL_DIR="/usr/local/XrayR"

echo "安装 XrayR $XRAYR_VERSION ..."

cd /tmp
curl -L -o xrayr.zip \
https://github.com/XrayR-project/XrayR-release/releases/download/${XRAYR_VERSION}/XrayR-linux-64.zip

mkdir -p $INSTALL_DIR
unzip -o xrayr.zip -d $INSTALL_DIR
chmod +x $INSTALL_DIR/XrayR

# systemd
cat > /etc/systemd/system/XrayR.service <<EOF
[Unit]
Description=XrayR Service
After=network.target

[Service]
Type=simple
ExecStart=$INSTALL_DIR/XrayR -config /etc/XrayR/config.yml
Restart=always
LimitNOFILE=51200

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload

# ===============================
# 面板信息
# ===============================
read -p "API Host: " API_HOST
read -p "ApiKey: " API_KEY
read -p "NodeID: " NODE_ID

# ===============================
# Shadowsocks 端口
# ===============================
echo
echo "选择端口："
echo "1) 443"
echo "2) 8443"
echo "3) 自定义(>10000)"
read -p "选择 [1-3]: " P

case $P in
1) PORT=443 ;;
2) PORT=8443 ;;
3)
    read -p "输入端口: " PORT
    if [[ ! "$PORT" =~ ^[0-9]+$ ]] || [ "$PORT" -le 10000 ]; then
        echo "❌ 端口必须 >10000"
        exit 1
    fi
    ;;
*) echo "❌ 错误"; exit 1 ;;
esac

# ===============================
# SS 密码
# ===============================
PASSWORD=$(openssl rand -base64 12)

echo "生成 SS 密码: $PASSWORD"

# ===============================
# 写入 XrayR 配置
# ===============================
mkdir -p /etc/XrayR

cat > /etc/XrayR/config.yml <<EOF
Log:
  Level: warning

Nodes:
  - PanelType: "NewV2board"
    ApiConfig:
      ApiHost: "$API_HOST"
      ApiKey: "$API_KEY"
      NodeID: $NODE_ID
      NodeType: Shadowsocks

    ControllerConfig:
      ListenIP: 0.0.0.0
      UpdatePeriodic: 60

      SS:
        Enable: true
        Method: "aes-256-gcm"
        Password: "$PASSWORD"
EOF

# ===============================
# 防火墙
# ===============================
ufw allow $PORT/tcp
ufw allow $PORT/udp
ufw --force enable

# ===============================
# 启动
# ===============================
systemctl enable XrayR
systemctl restart XrayR

# ===============================
# 输出
# ===============================
echo
echo "======================================"
echo "✅ Shadowsocks 部署完成"
echo "======================================"
echo "Port:     $PORT"
echo "Method:   aes-256-gcm"
echo "Password: $PASSWORD"
echo "======================================"
