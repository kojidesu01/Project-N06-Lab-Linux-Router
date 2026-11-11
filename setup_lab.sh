
#!/usr/bin/env bash
set -euo pipefail

# N06 - Linux Router Lab Setup

# Require root
if [ "$(id -u)" -ne 0 ]; then
    echo "[ERROR] Please run with sudo"
    exit 1
fi

# 1. Create network namespaces
ip netns add n06-pca
ip netns add n06-router
ip netns add n06-pcb

# 2. Create virtual Ethernet pairs
ip link add veth-pca type veth peer name veth-ra
ip link add veth-pcb type veth peer name veth-rb

# 3. Move interfaces into namespaces
ip link set veth-pca netns n06-pca
ip link set veth-ra netns n06-router

ip link set veth-pcb netns n06-pcb
ip link set veth-rb netns n06-router

# 4. Assign IP addresses
ip -n n06-pca addr add 10.10.1.10/24 dev veth-pca
ip -n n06-router addr add 10.10.1.1/24 dev veth-ra

ip -n n06-pcb addr add 10.10.2.10/24 dev veth-pcb
ip -n n06-router addr add 10.10.2.1/24 dev veth-rb

# 5. Enable all interfaces
ip -n n06-pca link set veth-pca up
ip -n n06-router link set veth-ra up

ip -n n06-pcb link set veth-pcb up
ip -n n06-router link set veth-rb up

# 6. Enable loopback interfaces
ip -n n06-pca link set lo up
ip -n n06-router link set lo up
ip -n n06-pcb link set lo up

# 7. Configure default gateways
ip -n n06-pca route add default via 10.10.1.1
ip -n n06-pcb route add default via 10.10.2.1

# 8. Enable IPv4 forwarding on router
ip netns exec n06-router sysctl -w net.ipv4.ip_forward=1

echo "[PASS] N06 Linux Router Lab setup complete"
