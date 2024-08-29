# Setup iptables for intercepting DNS requests
set -x -e

# TODO switch to nftables
echo TODO switch to nftables
exit 0



# Install iptables packages
echo iptables-persistent iptables-persistent/autosave_v4 booean false | debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 booean false | debconf-set-selections
DEBIAN_FRONTEND=noninteractive apt-get -y install iptables-persistent

# disable systemd services (qubes has its own systemd qubes-iptables.service)
systemctl disable netfilter-persistent.service



# Enable incoming traffic to be forwareded to loopback
if ! grep -q route_localnet=1 /etc/sysctl.d/99-sysctl.conf; then
    echo "net.ipv4.conf.all.route_localnet=1" | tee -a /etc/sysctl.d/99-sysctl.conf
    #echo "net.ipv6.conf.all.route_localnet=1" | tee -a /etc/sysctl.d/99-sysctl.conf
fi

# Redirect all DNS traffic to localhost
iptables -t nat -F PR-QBS
iptables -t nat -A PR-QBS -i vif+ -p udp -m udp --dport 53 -j DNAT --to-destination 127.0.2.1
iptables -t nat -A PR-QBS -i vif+ -p tcp -m tcp --dport 53 -j DNAT --to-destination 127.0.2.1

# Accept incoming DNS on localhost
iptables -I INPUT -i vif+ -p udp --dport 53 -j ACCEPT
iptables -I INPUT -i vif+ -p tcp --dport 53 -j ACCEPT

# Block other unencrypted DNS traffic
iptables -A FORWARD -p udp --dport 53 -j REJECT
iptables -A FORWARD -p tcp --dport 53 -j REJECT

# Block queries via ipv6
ip6tables -I INPUT -i any -p udp --dport 53 -j REJECT
ip6tables -I INPUT -i any -p tcp --dport 53 -j REJECT
ip6tables -I FORWARD -p udp --dport 53 -j REJECT
ip6tables -I FORWARD -p tcp --dport 53 -j REJECT



# Save rules
iptables-save | tee /etc/qubes/iptables.rules
ip6tables-save | tee /etc/iptables/ip6tables.rules
