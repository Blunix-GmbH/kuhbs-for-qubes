#!/bin/bash
#
# Install signal via apt
# Doc: https://signal.org/en/download/linux/
# Note: I'm also confused about the "xenial" for all linux based distros...

set -e -x



# 1. Install our official public software signing key:
wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > /usr/share/keyrings/signal-desktop-keyring.gpg

# 2. Add our repository to your list of repositories:
echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] http://updates.signal.org/desktop/apt xenial main' | tee /etc/apt/sources.list.d/signal-xenial.list

# 3. Update your package database and install Signal:
apt-get update
apt-get --yes install signal-desktop
