#!/usr/bin/env bash
# ==========================================
# XrayR Reality 一键部署脚本（增强防错版）
# VLESS + Reality | Debian12 / Ubuntu20+
# ==========================================

set -e

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

echo "更新系统并安装依赖..."
apt update && apt install -y vim chrony unzip curl openssl ufw

# ===============================
# 时间同步
# ===============================
echo "配置时间同步..."
systemctl enable chrony
systemctl restart chrony
chronyc makestep
timedatectl set-timezone UTC

# ===============================
# OS 检测
# ===============================
check_os() {
    . /etc/os-release
    echo "系统: $NAME $VERSION_ID"

    if [[ "$NAME" =~ "Debian" ]] && [[ "$(echo $VERSION_ID | cut -d'.' -f1)" -ge 12 ]]; then
        echo "✅ Debian 支持"
    elif [[ "$NAME" =~ "Ubuntu" ]]; then
        echo "✅ Ubuntu 支持"
    else
        echo "❌ 不支持系统"
        exit 1
    fi
}
check_os

# ===============================
# 安装 XrayR
# ===============================
echo "安装 XrayR..."
bash <(curl -sL https://raw.githubusercontent.com/XrayR-project/XrayR-release/master/install.sh)

XRAYR_BIN="/usr/local/XrayR/XrayR"
chmod +x $XRAYR_BIN

# ===============================
# 输入面板信息
# ===============================
read -p "API Host (https://xxx.com): " API_HOST
read -p "ApiKey: " API_KEY
read -p "NodeID: " NODE_ID

[ -z "$API_HOST" ] && echo "❌ API_HOST不能为空" && exit 1
[ -z "$API_KEY" ] && echo "❌ API_KEY不能为空" && exit 1
[ -z "$NODE_ID" ] && echo "❌ NODE_ID不能为空" && exit 1

# ===============================
# 伪装站点
# ===============================
echo
echo "选择伪装站点："
echo "1) www.microsoft.com"
echo "2) www.amazon.com"
echo "3) www.cloudflare.com"
echo "4) www.tesla.com"
read -p "输入 [1-4]: " SITE

case $SITE in
1) DEST="www.microsoft.com:443"; SNI="www.microsoft.com" ;;
2) DEST="www.amazon.com:443"; SNI="www.amazon.com" ;;
3) DEST="www.cloudflare.com:443"; SNI="www.cloudflare.com" ;;
4) DEST="www.tesla.com:443"; SNI="www.tesla.com" ;;
*) echo "❌ 无效选择"; exit 1 ;;
esac

# ===============================
# Reality 模式选择
# ===============================
echo
echo "部署模式："
echo "1) 全新节点（自动生成）"
echo "2) 替换旧节点（手动输入）"
read -p "输入 [1-2]: " MODE

if [ "$MODE" = "1" ]; then
    echo "生成密钥..."
    KEY=$($XRAYR_BIN x25519)

    PRIVATE_KEY=$(echo "$KEY" | grep "Private" | awk '{print $3}')
    PUBLIC_KEY=$(echo "$KEY" | grep "Public" | awk '{print $3}')
    SHORT_ID=$(openssl rand -hex 8)

elif [ "$MODE" = "2" ]; then
    read -p "PrivateKey: " PRIVATE_KEY
    read -p "PublicKey: " PUBLIC_KEY
    read -p "ShortID: " SHORT_ID

else
    echo "❌ 输入错误"
    exit 1
fi

# ===============================
# 参数校验（关键防翻车）
# ===============================
echo "校验参数..."

[[ ${#PRIVATE_KEY} -lt 40 ]] && echo "❌ PrivateKey错误" && exit 1
[[ ${#PUBLIC_KEY} -lt 40 ]] && echo "❌ PublicKey错误" && exit 1

if ! [[ "$SHORT_ID" =~ ^[0-9a-fA-F]{2,16}$ ]]; then
    echo "❌ ShortID必须是16进制(2-16位)"
    exit 1
fi

# ===============================
# 写入配置
# ===============================
cat > /etc/XrayR/config.yml <<EOF
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

    ControllerConfig:
      ListenIP: 0.0.0.0
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

      CertConfig:
        CertMode: none
EOF

# ===============================
# BBR优化
# ===============================
cat > /etc/sysctl.d/99-xrayr.conf <<SYSCTL
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
net.ipv4.tcp_fastopen=3
SYSCTL

sysctl --system

# ===============================
# 防火墙
# ===============================
ufw allow 443/tcp
ufw allow 443/udp
ufw --force enable

# ===============================
# 启动
# ===============================
systemctl enable XrayR
systemctl restart XrayR

# ===============================
# 输出结果
# ===============================
echo
echo "======================================"
echo "✅ 部署完成"
echo "======================================"
echo "SNI:        $SNI"
echo "PrivateKey: $PRIVATE_KEY"
echo "PublicKey:  $PUBLIC_KEY"
echo "ShortID:    $SHORT_ID"
echo "======================================"
echo "⚠ 客户端必须使用以上参数"
