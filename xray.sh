bash <(cat << 'EOF'
#!/bin/bash

set -e

echo "======================================"
echo " XrayR 部署脚本（Reality 专业版）"
echo "======================================"
echo ""
echo "请选择部署模式："
echo "1️⃣ 全新节点（自动生成密钥）"
echo "2️⃣ 替换旧节点（复用旧密钥）"
echo ""

read -p "请输入选项 (1 或 2): " MODE

# ===== 输入面板信息 =====
read -p "👉 面板地址（如 https://example.com）: " API_HOST
read -p "👉 ApiKey: " API_KEY
read -p "👉 NodeID: " NODE_ID

# ===== 处理模式 =====
if [ "$MODE" == "1" ]; then
    echo ""
    echo "==== 生成 Reality 密钥 ===="
    KEYS=$(/usr/local/XrayR/XrayR x25519)
    PRIVATE_KEY=$(echo "$KEYS" | grep PrivateKey | awk '{print $2}')
    PUBLIC_KEY=$(echo "$KEYS" | grep PublicKey | awk '{print $2}')

    SHORT_ID=$(openssl rand -hex 4)

elif [ "$MODE" == "2" ]; then
    echo ""
    echo "⚠️ 替换节点模式：请输入旧参数"

    read -p "👉 PrivateKey: " PRIVATE_KEY
    read -p "👉 shortId: " SHORT_ID
    read -p "👉 PublicKey（用于显示）: " PUBLIC_KEY

else
    echo "❌ 输入错误"
    exit 1
fi

# ===== 安装 XrayR =====
wget -N https://raw.githubusercontent.com/XrayR-project/XrayR-release/master/install.sh && bash install.sh

# ===== 写配置 =====
cat > /etc/XrayR/config.yml <<EOF2
Log:
  Level: warning

Nodes:
  - PanelType: "NewV2board"
    ApiConfig:
      ApiHost: "$API_HOST"
      ApiKey: "$API_KEY"
      NodeID: $NODE_ID
      NodeType: Vless

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
          - "$SHORT_ID"

      CertConfig:
        CertMode: none
EOF2

# ===== 启动 =====
systemctl enable XrayR
systemctl restart XrayR

echo ""
echo "======================================"
echo "✅ 部署完成"
echo ""
echo "👉 PublicKey: $PUBLIC_KEY"
echo "👉 shortId:   $SHORT_ID"
echo "======================================"

EOF
)
