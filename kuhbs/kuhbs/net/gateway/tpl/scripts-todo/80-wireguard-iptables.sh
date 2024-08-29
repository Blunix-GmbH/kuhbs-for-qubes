# Setup iptables for blocking everything except wireguard
set -x -e



# Install iptables packages
echo iptables-persistent iptables-persistent/autosave_v4 booean false | debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 booean false | debconf-set-selections
DEBIAN_FRONTEND=noninteractive apt-get -y install iptables-persistent

# disable systemd services (qubes has its own systemd qubes-iptables.service)
systemctl disable netfilter-persistent.service



# Block all connections thorugh regular upstread device in case vpn goes down
iptables -I FORWARD -i eth0 -j DROP
iptables -I FORWARD -o eth0 -j DROP
ip6tables -I FORWARD -i eth0 -j DROP
ip6tables -I FORWARD -o eth0 -j DROP

# Accept VPN traffic
iptables -F OUTPUT
iptables -P OUTPUT DROP
ip6tables -F OUTPUT
ip6tables -P OUTPUT DROP
iptables -A OUTPUT \
    -o eth0 -p udp -d \
    138.199.6.194,138.199.6.207,138.199.6.220,138.199.6.233,146.70.126.162,146.70.126.194,146.70.126.226,146.70.134.2,146.70.134.34,146.70.134.66,146.70.134.98,179.43.189.66,193.32.127.66,193.32.127.67,193.32.127.68,193.32.127.69,193.32.127.70,193.32.127.84,46.19.136.226 \
    --dport 51820 -j ACCEPT



# Save rules
iptables-save | tee /etc/qubes/iptables.rules
ip6tables-save | tee /etc/iptables/ip6tables.rules
