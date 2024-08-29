#!/bin/bash
#
# Setup packages required for update, clock VM, ...

set -e -x



DEBIAN_FRONTEND=noninteractive apt-get -y install qubes-core-agent-dom0-updates systemd-timesyncd

systemctl enable systemd-timesyncd.service
