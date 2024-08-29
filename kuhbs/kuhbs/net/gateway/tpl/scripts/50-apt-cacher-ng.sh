#!/bin/bash
#
# Setup apt-cacher-ng

set -e -x




DEBIAN_FRONTEND=noninteractive apt-get --yes install apt-cacher-ng

cp -v /home/user/QubesIncoming/dom0/kuh-templates/apt-cacher-ng/acng.conf /etc/apt-cacher-ng/acng.conf
chown -v root:root /etc/apt-cacher-ng/acng.conf
chmod -v 644 /etc/apt-cacher-ng/acng.conf

systemctl enable apt-cacher-ng.service

# TODO
exit
/usr/sbin/nft insert rule qubes custom-input tcp dport 8082 accept
echo '/usr/sbin/nft insert rule qubes custom-input tcp dport 8082 accept' > /root/ufw.sh
chmod 700 /root/ufw.sh
