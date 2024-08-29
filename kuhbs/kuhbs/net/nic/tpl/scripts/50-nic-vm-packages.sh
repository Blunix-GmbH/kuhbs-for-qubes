#!/bin/bash
#
# Install packages required for the VM that has the network PCI device assigned

set -e -x



DEBIAN_FRONTEND=noninteractive apt-get -y install \
    qubes-core-agent-networking \
    qubes-core-agent-network-manager \
    qubes-core-agent-dom0-updates \
    firmware-iwlwifi \
    nmap \
    openssh-client \
    iputils-ping \
    iputils-arping \
    firefox-esr
