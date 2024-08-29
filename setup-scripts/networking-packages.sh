# Install everything required for VMs that have anything to do with networking, like having a netvm or providing network to other VMs
DEBIAN_FRONTEND=noninteractive apt-get --yes install qubes-core-agent-networking lsof tcpdump wireshark-gtk bind9-host iftop apt-transport-https net-tools
