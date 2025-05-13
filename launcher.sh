#!/bin/bash

set -e

sudo apt update -y
sudo apt install -y strongswan strongswan-pki libcharon-extra-plugins iptables-persistent

echo "Killing previous connections"
sudo ipsec down test || true

echo "Stopping strongSwan..."
sudo systemctl stop strongswan-starter || true

clear
echo "server IP:"
read SERVER_IP
echo "PSK:"
read PSK

echo "Updating configuration /etc/ipsec.conf..."
sudo bash -c "cat > /etc/ipsec.conf" <<EOF
config setup
    charondebug="all"

conn test
    keyexchange=ikev2
    authby=secret
    ike=aes256-sha256-modp2048
    esp=aes256-sha256

    left=%defaultroute
    leftsourceip=%config

    right=${SERVER_IP}
    rightsubnet=0.0.0.0/0

    auto=start
EOF

echo "Configuring /etc/ipsec.secrets..."
sudo bash -c "cat > /etc/ipsec.secrets" <<EOF
: PSK "${PSK}"
EOF

echo "Updating..."
sudo systemctl daemon-reload
clear
echo "Updating."
sudo systemctl restart strongswan-starter
clear
echo "Testing..."
sleep 3
clear
echo "Open connection..."
sudo ipsec up test
sudo ipsec statusall

echo "VPN is ready to use! Local server: ${SERVER_IP}"
echo "Use sudo ipsec statusall for detailed information"
