# Setup kicksecure
# Doc: https://www.kicksecure.com/wiki/Debian


# Download signing key
curl --tlsv1.3 --output /usr/share/keyrings/derivative.asc --url https://www.kicksecure.com/keys/derivative.asc

# Add clearnet repo
echo "deb [signed-by=/usr/share/keyrings/derivative.asc] https://deb.kicksecure.com bookworm main contrib non-free" | tee /etc/apt/sources.list.d/derivative.list
apt-get update

# Install kicksecure
apt-get --yes install --no-install-recommends kicksecure-qubes-cli
