#!/usr/bin/env bash
# ==========================================
# XrayR Reality 一键部署脚本（Debian12 / Ubuntu20.04+）
# 支持 VLESS+Reality，多短ID、多SNI，自动生成 PrivateKey
# ==========================================

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

apt update && apt install unzip curl -y

red='\033[31m'
green='\033[32m'
cclear='\033[0m'

echo "设置时区为香港..."
rm -f /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Hong_Kong /etc/localtime

# ===============================
# OS 检测和版本校验
# ===============================
check_os() {
    echo "检测操作系统..."
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS_NAME=$NAME
        OS_VERSION=$VERSION_ID
    else
        OS_NAME=$(uname -s)
        OS_VERSION=$(uname -r)
    fi
    echo "操作系统: $OS_NAME"
    echo "版本: $OS_VERSION"

    # 校验系统版本
    if [[ "$OS_NAME" =~ "Debian" ]] && [[ "$(echo $OS_VERSION | cut -d'.' -f1)" -ge 12 ]]; then
        read -n1 -r -p "系统符合安装条件 ✅，按任意键继续..."
    elif [[ "$OS_NAME" =~ "Ubuntu" ]]; then
        ver_major=$(echo $OS_VERSION | cut -d'.' -f1)
        ver_minor=$(echo $OS_VERSION | cut -d'.' -f2)
        if [[ $ver_major -gt 20 ]] || { [[ $ver_major -eq 20 ]] && [[ $ver_minor -ge 04 ]]; }; then
            read -n1 -r -p "系统符合安装条件 ✅，按任意键继续..."
        else
            read -n1 -r -p "⚠️ Ubuntu 版本过低，需要 Ubuntu 20.04 以上，按任意键退出脚本..."
            exit 1
        fi
    else
        read -n1 -r -p "⚠️ 不支持的操作系统: $OS_NAME，按任意键退出脚本..."
        exit 1
    fi
}
check_os

# =====================================
# 安装 XrayR 最新版
# =====================================
echo "下载并安装 XrayR 最新版..."
bash <(curl -sL https://raw.githubusercontent.com/XrayR-project/XrayR-release/master/install.sh)

XRAYR_BIN="/usr/local/XrayR/XrayR"
chmod +x $XRAYR_BIN

# =====================================
# 用户交互输入
# =====================================
read -p "请输入面板 API Host (例如 https://kochir.com): " API_HOST
read -p "请输入面板 ApiKey: " API_KEY
read -p "请输入 NodeID (数字): " NODE_ID

echo
echo "选择 Reality 节点密钥模式："
echo "1) 全新生成 PrivateKey + 三个短ID"
echo "2) 使用已有节点 PrivateKey + 三个短ID"
read -p "请输入选项 [1/2]: " KEY_MODE

if [[ "$KEY_MODE" == "1" ]]; then
    PRIVATE_KEY=$($XRAYR_BIN x25519)
    echo "生成 PrivateKey: $PRIVATE_KEY"
    SHORT_ID1=$(tr -dc A-Za-z0-9 </dev/urandom | head -c12)
    SHORT_ID2=$(tr -dc A-Za-z0-9 </dev/urandom | head -c12)
    SHORT_ID3=$(tr -dc A-Za-z0-9 </dev/urandom | head -c12)
else
    read -p "请输入已有 PrivateKey: " PRIVATE_KEY
    read -p "请输入第1个短ID (12位): " SHORT_ID1
    read -p "请输入第2个短ID (12位): " SHORT_ID2
    read -p "请输入第3个短ID (12位): " SHORT_ID3
fi

# =====================================
# 生成 XrayR 配置文件
# =====================================
CONFIG_FILE="/etc/XrayR/config.yml"
cat > $CONFIG_FILE <<EOF
Log:
  Level: warning
  AccessPath:
  ErrorPath:

ConnectionConfig:
  Handshake: 4
  ConnIdle: 30
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
      EnableVless: true
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
        Dest: www.apple.com:443
        ServerNames:
          - www.apple.com
          - www.microsoft.com
          - www.amazon.com
        PrivateKey: "$PRIVATE_KEY"
        ShortIds:
          - "$SHORT_ID1"
          - "$SHORT_ID2"
          - "$SHORT_ID3"

      CertConfig:
        CertMode: none
EOF

# =====================================
# 内核网络优化
# =====================================
echo "应用内核网络优化参数..."
cat >> /etc/sysctl.conf <<SYSCTL
# Reality / XrayR 高性能网络优化
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
net.ipv4.tcp_fastopen=3
net.ipv4.tcp_fin_timeout=15
net.ipv4.tcp_tw_reuse=1
net.ipv4.ip_local_port_range=1024 65535
net.core.somaxconn=65535
net.core.netdev_max_backlog=65535
SYSCTL

sysctl -p

# =====================================
# 启动并启用 XrayR 服务
# =====================================
systemctl daemon-reload
systemctl enable XrayR
systemctl restart XrayR

# =====================================
# 输出信息
# =====================================
echo
echo "✅ XrayR Reality 节点部署完成！"
echo "PrivateKey: $PRIVATE_KEY"
echo "ShortIds: $SHORT_ID1, $SHORT_ID2, $SHORT_ID3"
echo -e "${green}OS : $OS_NAME $OS_VERSION ${cclear}"
