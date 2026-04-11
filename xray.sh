#!/usr/bin/env bash
# ==========================================
# XrayR Reality 一键部署脚本（优化版）
# 支持 VLESS+Reality（高隐蔽 + 稳定）
# Debian12 / Ubuntu20.04+
# ==========================================

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

echo "更新系统并安装依赖..."
apt update && apt install -y vim chrony unzip curl openssl

# ===============================
# 时间同步 + 时区优化
# ===============================
echo "配置时间同步..."
systemctl enable chrony
systemctl restart chrony
chronyc makestep

echo "设置时区为 UTC"
timedatectl set-timezone UTC

# ===============================
# OS 检测
# ===============================
check_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS_NAME=$NAME
        OS_VERSION=$VERSION_ID
    else
        echo "无法检测系统"
        exit 1
    fi

    echo "系统: $OS_NAME $OS_VERSION"

    if [[ "$OS_NAME" =~ "Debian" ]] && [[ "$(echo $OS_VERSION | cut -d'.' -f1)" -ge 12 ]]; then
        echo "✅ Debian 支持"
    elif [[ "$OS_NAME" =~ "Ubuntu" ]]; then
        ver_major=$(echo $OS_VERSION | cut -d'.' -f1)
        ver_minor=$(echo $OS_VERSION | cut -d'.' -f2)
        if [[ $ver_major -gt 20 ]] || { [[ $ver_major -eq 20 ]] && [[ $ver_minor -ge 04 ]]; }; then
            echo "✅ Ubuntu 支持"
        else
            echo "❌ Ubuntu 版本过低"
            exit 1
        fi
    else
        echo "❌ 不支持系统"
        exit 1
    fi
}
check_os

# ===============================
# 安装 XrayR（锁版本）
# ===============================
echo "安装 XrayR..."
bash <(curl -sL https://raw.githubusercontent.com/XrayR-project/XrayR-release/master/install.sh)

XRAYR_BIN="/usr/local/XrayR/XrayR"
chmod +x $XRAYR_BIN

# ===============================
# 用户输入
# ===============================
read -p "请输入面板 API Host (例如 https://aaa.com): " API_HOST
read -p "请输入面板 ApiKey: " API_KEY
read -p "请输入 NodeID: " NODE_ID

echo
echo "请选择伪装站点："
echo "1) www.microsoft.com"
echo "2) www.amazon.com"
echo "3) www.cloudflare.com"
echo "4) www.tesla.com"
read -p "输入选项 [1-4]: " SITE_CHOICE

case $SITE_CHOICE in
    1) DEST="www.microsoft.com:443"; SNI="www.microsoft.com" ;;
    2) DEST="www.amazon.com:443"; SNI="www.amazon.com" ;;
    3) DEST="www.cloudflare.com:443"; SNI="www.cloudflare.com" ;;
    4) DEST="www.tesla.com:443"; SNI="www.tesla.com" ;;
    *) echo "无效选项"; exit 1 ;;
esac

# ===============================
# 生成 Reality 密钥 + ShortID
# ===============================
echo "生成 Reality 密钥..."
KEY_OUTPUT=$($XRAYR_BIN x25519)

PRIVATE_KEY=$(echo "$KEY_OUTPUT" | sed -n 's/Private key: //p')
PUBLIC_KEY=$(echo "$KEY_OUTPUT" | sed -n 's/Public key: //p')

SHORT_ID=$(openssl rand -hex 8)

echo "PrivateKey: $PRIVATE_KEY"
echo "PublicKey:  $PUBLIC_KEY"
echo "ShortID:    $SHORT_ID"

# ===============================
# 写入配置
# ===============================
CONFIG_FILE="/etc/XrayR/config.yml"

cat > $CONFIG_FILE <<EOF
Log:
  Level: warning

ConnectionConfig:
  Handshake: 8
  ConnIdle: 120
  UplinkOnly: 2
  DownlinkOnly: 4
  BufferSize: 64

Nodes:
  - PanelType: "NewV2board"
    ApiConfig:
      ApiHost: "$API_HOST"
      ApiKey: "$API_KEY"
      NodeID: $NODE_ID
      NodeType: Vless
      Timeout: 30
      VlessFlow: "xtls-rprx-vision"
      SpeedLimit: 0
      DeviceLimit: 0
      DisableCustomConfig: false

    ControllerConfig:
      ListenIP: 0.0.0.0
      SendIP: 0.0.0.0
      UpdatePeriodic: 60

      EnableREALITY: true
      REALITYConfigs:
        Show: false
        Dest: $DEST
        ServerNames:
          - $SNI

        PrivateKey: "$PRIVATE_KEY"
        ShortIds:
          - "$SHORT_ID"

        MinClientVer: ""
        MaxClientVer: ""
        MaxTimeDiff: 0

      CertConfig:
        CertMode: none
EOF

# ===============================
# BBR + 网络优化（增强版）
# ===============================
echo "优化内核参数..."

cat > /etc/sysctl.d/99-xrayr.conf <<SYSCTL
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
net.ipv4.tcp_fastopen=3
net.ipv4.tcp_fin_timeout=15
net.ipv4.tcp_tw_reuse=1
net.ipv4.ip_local_port_range=1024 65535
net.core.somaxconn=65535
net.core.netdev_max_backlog=65535
SYSCTL

sysctl --system

# 确保 bbr 加载
modprobe tcp_bbr 2>/dev/null

echo "BBR 状态:"
sysctl net.ipv4.tcp_congestion_control

# ===============================
# 防火墙放行
# ===============================
echo "配置防火墙..."
apt install -y ufw
ufw allow 443/tcp
ufw allow 443/udp
ufw --force enable

# ===============================
# 启动服务
# ===============================
systemctl daemon-reload
systemctl enable XrayR
systemctl restart XrayR

# ===============================
# 完成
# ===============================
echo
echo "======================================"
echo "✅ 部署完成"
echo "======================================"
echo "节点伪装: $SNI"
echo "PrivateKey: $PRIVATE_KEY"
echo "PublicKey:  $PUBLIC_KEY"
echo "ShortID:    $SHORT_ID"
echo "======================================"
