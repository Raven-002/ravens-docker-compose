#!/bin/bash

set -e

echo "Starting RavenDB..."
echo "Don't forget to set access permissions for for the chosen group"

cat /opt/raven-compose/base.env /opt/raven-compose/secrets.env > /opt/raven-compose/.env
HOSTNAME=$(hostname | awk '{print $1;}') \
LISTENING_HOSTNAME=$(hostname | awk '{print $1;}') \
echo "HOSTNAME=$HOSTNAME" >> /opt/raven-compose/.env
echo "LISTENING_HOSTNAME=$LISTENING_HOSTNAME" >> /opt/raven-compose/.env

LAN_IF="enp63s0u1u4u1"       # change to your LAN interface
VPN_IF="wg0"
VPN_SUBNET="192.168.2.0/24"

# 1️⃣ Enable IP forwarding
if [ "$(sysctl -n net.ipv4.ip_forward)" -ne 1 ]; then
    echo "[INFO] Enabling IP forwarding..."
    sudo sysctl -w net.ipv4.ip_forward=1
fi

# 2️⃣ Enable proxy ARP on LAN interface
if [ "$(sysctl -n net.ipv4.conf.$LAN_IF.proxy_arp)" -ne 1 ]; then
    echo "[INFO] Enabling proxy ARP on $LAN_IF..."
    sudo sysctl -w net.ipv4.conf.$LAN_IF.proxy_arp=1
fi

echo "[INFO] Pre-flight network checks complete. Starting Docker Compose..."

docker compose -f /opt/raven-compose/docker-compose.yml down "${@}"
docker compose \
    -f /opt/raven-compose/docker-compose.yml \
    --env-file /opt/raven-compose/.env \
    up \
    -d \
    "${@}"

# 3️⃣ Add VPN subnet route if missing
if ! ip route show | grep -q "$VPN_SUBNET"; then
    echo "[INFO] Adding route for VPN subnet $VPN_SUBNET via $VPN_IF..."
    sudo ip route add $VPN_SUBNET dev $VPN_IF
fi

# # 4️⃣ Optional: Add NAT rules if needed
# if ! sudo iptables -t nat -C POSTROUTING -s $VPN_SUBNET -o $LAN_IF -j MASQUERADE &>/dev/null; then
#     echo "[INFO] Adding NAT for VPN subnet to access internet..."
#     sudo iptables -t nat -A POSTROUTING -s $VPN_SUBNET -o $LAN_IF -j MASQUERADE
#     sudo iptables -A FORWARD -i $VPN_IF -j ACCEPT
#     sudo iptables -A FORWARD -o $VPN_IF -j ACCEPT
# fi
