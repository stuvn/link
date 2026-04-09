#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

apt update && apt install unzip -y

red='\033[31m'
green='\033[32m'
cclear='\033[0m'

echo "setting timezone ..."
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

    # 校验系统
    if [[ "$OS_NAME" =~ "Debian" ]] && [[ "$(echo $OS_VERSION | cut -d'.' -f1)" -ge 12 ]]; then
        echo "系统符合安装条件 ✅"
        read -n1 -r -p "按任意键继续部署脚本..."
    elif [[ "$OS_NAME" =~ "Ubuntu" ]]; then
        ver_major=$(echo $OS_VERSION | cut -d'.' -f1)
        ver_minor=$(echo $OS_VERSION | cut -d'.' -f2)
        if [[ $ver_major -gt 20 ]] || { [[ $ver_major -eq 20 ]] && [[ $ver_minor -ge 04 ]]; }; then
            echo "系统符合安装条件 ✅"
            read -n1 -r -p "按任意键继续部署脚本..."
        else
            echo "⚠️ 你的 Ubuntu 版本过低，需要 Ubuntu 20.04 以上"
            read -n1 -r -p "按任意键退出脚本..."
            exit 1
        fi
    else
        echo "⚠️ 不支持的操作系统: $OS_NAME"
        read -n1 -r -p "按任意键退出脚本..."
        exit 1
    fi
}

# ===============================
# 调用函数
# ===============================
check_os

# =====================================
# 一键部署 XrayR + VLESS+Reality (多SNI+多短ID)
# 适用于 Debian 12
# =====================================

set -e

echo "=============================="
echo "🚀 XrayR Reality 一键部署脚本"
echo "=============================="
echo

# -------------------------------
# 交互输入
# -------------------------------
read -p "请输入面板 API Host (例如 https://kochir.com): " API_HOST
read -p "请输入面板 ApiKey: " API_KEY
read -p "请输入 NodeID (数字): " NODE_ID

echo
echo "选择 Reality 节点密钥模式："
echo "1) 全新生成 PrivateKey + 短ID"
echo "2) 使用已有节点 PrivateKey + 短ID"
read -p "请输入选项 [1/2]: " KEY_MODE

if [[ "$KEY_MODE" == "1" ]]; then
    PRIVATE_KEY=$(./XrayR x25519) 2>/dev/null
    echo "生成 PrivateKey: $PRIVATE_KEY"
    # 生成三个随机12位短ID
    SHORT_ID1=$(tr -dc A-Za-z0-9 </dev/urandom | head -c12)
    SHORT_ID2=$(tr -dc A-Za-z0-9 </dev/urandom | head -c12)
    SHORT_ID3=$(tr -dc A-Za-z0-9 </dev/urandom | head -c12)
else
    read -p "请输入已有 PrivateKey: " PRIVATE_KEY
    read -p "请输入第1个短ID (12位): " SHORT_ID1
    read -p "请输入第2个短ID (12位): " SHORT_ID2
    read -p "请输入第3个短ID (12位): " SHORT_ID3
fi

# -------------------------------
# 安装 XrayR 最新版
# -------------------------------
echo "下载并安装 XrayR 最新版..."
bash <(curl -sL https://github.com/XrayR-project/XrayR-install/raw/main/install.sh)

# -------------------------------
# 配置文件生成
# -------------------------------
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
      EnableVless: false
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

# -------------------------------
# 内核优化（可选，可整合前面的优化）
# -------------------------------
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

# -------------------------------
# 重启 XrayR
# -------------------------------
echo "启动并启用 XrayR 服务..."
systemctl daemon-reload
systemctl enable XrayR
systemctl restart XrayR

echo
echo "✅ XrayR Reality 多SNI + 多短ID 节点部署完成！"
echo "PrivateKey: $PRIVATE_KEY"
echo "ShortIds: $SHORT_ID1, $SHORT_ID2, $SHORT_ID3"
echo
echo "请确保面板已正确同步节点信息。"

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
