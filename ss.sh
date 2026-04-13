#!/usr/bin/env bash
# ==========================================
# XrayR Worker 生产级标准部署脚本
# 适配 XBoard / NewV2board API
# 官方最小可用配置（无业务字段）
# ==========================================

set -e

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# ===============================
# 基础依赖
# ===============================
echo "安装基础依赖..."
apt update && apt install -y curl unzip ufw chrony

# ===============================
# 时间同步（机场标准）
# ===============================
systemctl enable chrony
systemctl restart chrony
chronyc makestep
timedatectl set-timezone UTC

# ===============================
# 系统检查
# ===============================
. /etc/os-release
echo "系统: $NAME $VERSION_ID"

case "$NAME" in
  *Ubuntu*|*Debian*)
    echo "系统支持 ✔"
    ;;
  *)
    echo "❌ 不支持的系统"
    exit 1
    ;;
esac

# ===============================
# 安装 XrayR（官方）
# ===============================
echo "安装 XrayR..."
bash <(curl -Ls https://raw.githubusercontent.com/XrayR-project/XrayR-release/master/install.sh)

chmod +x /usr/local/XrayR/XrayR

# ===============================
# 机场唯一需要输入的信息
# ===============================
echo
echo "请输入面板信息（XBoard / NewV2board）"

read -p "API Host (https://xxx.com): " API_HOST
read -p "ApiKey: " API_KEY
read -p "NodeID: " NODE_ID

# ===============================
# 参数校验
# ===============================
if [[ -z "$API_HOST" || -z "$API_KEY" || -z "$NODE_ID" ]]; then
    echo "❌ 参数不能为空"
    exit 1
fi

# ===============================
# 写入 XrayR 配置（官方最小标准）
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
      Timeout: 30

    ControllerConfig:
      ListenIP: 0.0.0.0
      SendIP: 0.0.0.0
      UpdatePeriodic: 60
      EnableDNS: false

      CertConfig:
        CertMode: none
EOF

# ===============================
# 防火墙（仅系统级安全）
# ===============================
ufw allow OpenSSH
ufw default allow outgoing
ufw --force enable

# ===============================
# 启动服务
# ===============================
systemctl enable XrayR
systemctl restart XrayR

# ===============================
# 状态检查
# ===============================
sleep 2
systemctl status XrayR --no-pager || true

# ===============================
# 输出结果
# ===============================
echo
echo "======================================"
echo "✅ XrayR Worker 部署完成（官方标准版）"
echo "======================================"
echo "Panel:     XBoard / NewV2board"
echo "NodeID:    $NODE_ID"
echo "API Host:  $API_HOST"
echo "======================================"
echo "说明："
echo "- 本脚本不包含任何业务参数"
echo "- 端口 / 用户 / 密码 由面板控制"
echo "- 仅负责 Worker 连接与执行"
echo "======================================"
