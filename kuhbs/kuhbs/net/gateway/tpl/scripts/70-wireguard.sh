#!/bin/bash
#
# Setup wireguard

set -e -x



# Install wireguard
DEBIAN_FRONTEND=noninteractive apt-get -y install wireguard
chmod -v 700 /etc/wireguard
mv -v /home/user/QubesIncoming/dom0/kuh-templates/wireguard/configs/*.conf /etc/wireguard/
chmod -v 600 /etc/wireguard/*.conf

# Setup random config selection script
mv -v /home/user/QubesIncoming/dom0/kuh-templates/wireguard/wireguard-config-select.sh /usr/sbin/
chmod 700 /usr/sbin/wireguard-config-select.sh

# Setup systemd service
mv -v /home/user/QubesIncoming/dom0/kuh-templates/wireguard/wireguard.service /etc/systemd/system/
chmod 644 /etc/systemd/system/wireguard.service
systemctl daemon-reload
systemctl enable wireguard.service
