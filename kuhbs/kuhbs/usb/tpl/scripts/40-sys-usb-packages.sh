#!/bin/bash
#
# Install packages required for the VM that has the PCI USB controllers assigned

set -x -e



DEBIAN_FRONTEND=noninteractive apt-get -y install gparted qubes-usb-proxy cryptsetup
