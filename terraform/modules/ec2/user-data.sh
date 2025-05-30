#!/bin/bash

set -eux

# Install WireGuard, unzip, curl
apt update
apt install -y wireguard unzip curl

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
unzip -q /tmp/awscliv2.zip -d /tmp
/tmp/aws/install

# Make WireGuard directory and cd into it
WG_DIR="/etc/wireguard"
mkdir -p $WG_DIR
cd $WG_DIR

# Generate server and client keys
wg genkey | tee server_private.key | wg pubkey > server_public.key
wg genkey | tee client_private.key | wg pubkey > client_public.key

SERVER_PRIV_KEY=$(cat server_private.key)
SERVER_PUB_KEY=$(cat server_public.key)
CLIENT_PRIV_KEY=$(cat client_private.key)
CLIENT_PUB_KEY=$(cat client_public.key)

# Get public IP of EC2 instance
# Fetch IMDSv2 token
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

# Use token to get public IP
PUBLIC_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/public-ipv4)

# Get network interface id (enX0)
INTERFACE=$(ip -o -4 route show to default | awk '{print $5}')

# Generate server config with NAT rules
# Use IP address that does not overlap with the VPC
cat > wg0.conf <<EOF
[Interface]
PrivateKey = $SERVER_PRIV_KEY
Address = 10.100.0.1/24
ListenPort = 51820
SaveConfig = true
PostUp = iptables -t nat -A POSTROUTING -o $INTERFACE -j MASQUERADE
PostDown = iptables -t nat -D POSTROUTING -o $INTERFACE -j MASQUERADE

[Peer]
PublicKey = $CLIENT_PUB_KEY
AllowedIPs = 10.100.0.2/32
EOF

# Enable IP forwarding
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p

# Start WireGuard
systemctl enable wg-quick@wg0
systemctl start wg-quick@wg0

# Generate client config
cat > /tmp/wg-client.conf <<EOF
[Interface]
PrivateKey = $CLIENT_PRIV_KEY
Address = 10.100.0.2/24
DNS = 1.1.1.1

[Peer]
PublicKey = $SERVER_PUB_KEY
Endpoint = $PUBLIC_IP:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOF

# Upload client config to S3
aws s3 cp /tmp/wg-client.conf s3://${S3_BUCKET}/wg-client.conf