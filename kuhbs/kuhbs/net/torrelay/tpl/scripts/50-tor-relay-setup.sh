# Setup a tor relay node



# Add apt sources.list
cat << 'EOF' > /etc/apt/sources.list.d/tor.list
deb     [signed-by=/usr/share/keyrings/tor-archive-keyring.gpg] http://deb.torproject.org/torproject.org bookworm main
deb-src [signed-by=/usr/share/keyrings/tor-archive-keyring.gpg] http://deb.torproject.org/torproject.org bookworm main
EOF

# Download and import keyring
apt-get --yes install gnupg2
wget -qO- https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --dearmor | tee /usr/share/keyrings/tor-archive-keyring.gpg >/dev/null

# Install tor
apt update
apt-get --yes install tor deb.torproject.org-keyring

# Configure the relay
cat << 'EOF' >> /etc/tor/torrc
Nickname ididnteditheconfig
ContactInfo 0xFFFFFFFF Random Person <nobody AT example dot com>
ORPort 443
ExitRelay 0
SocksPort 0
RelayBandwidthRate 100 MBytes
RelayBandwidthBurst 120 MBytes
MaxAdvertisedBandwidth 100 MBytes
AccountingStart day 0:00
AccountingMax 200 GBytes
EOF
