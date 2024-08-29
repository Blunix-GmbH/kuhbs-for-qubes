# Setup nftables for intercepting DNS requests
set -x -e

echo TODO
exit 0



# Enable incoming traffic to be forwareded to loopback
if ! grep -q route_localnet=1 /etc/sysctl.d/99-sysctl.conf; then
    echo "net.ipv4.conf.all.route_localnet=1" | tee -a /etc/sysctl.d/99-sysctl.conf
    #echo "net.ipv6.conf.all.route_localnet=1" | tee -a /etc/sysctl.d/99-sysctl.conf
fi

# Redirect all DNS traffic to 127.0.2.1
nft add chain qubes nat { type nat hook prerouting priority dstnat\; }
nft add rule qubes nat iifname == "vif*" tcp dport 53 dnat 127.0.2.1
nft add rule qubes nat iifname == "vif*" udp dport 53 dnat 127.0.2.1

# TODO persistent
