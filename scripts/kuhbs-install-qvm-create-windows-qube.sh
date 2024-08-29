#!/bin/bash
#
# Setup qvm-create-windows-qube: https://github.com/ElliotKillick/qvm-create-windows-qube

set -e -x

download_vm=sys-firewall


# Clone git repo and copy it to dom0
qvm-run -u root $download_vm 'apt-get -y instal git'
qvm-run $download_vm 'git clone https://github.com/ElliotKillick/qvm-create-windows-qube'
qvm-run $download_vm 'tar cvzf fo.tar.gz qvm-create-windows-qube'
qvm-run --pass-io $download_vm 'cat fo.tar.gz' > fo.tar.gz
qvm-run $download_vm 'rm fo.tar.gz'

# Unpack and run installer
tar xvzf fo.tar.gz
rm -f fo.tar.gz
qvm-create-windows-qube/install.sh

# Download windows version using the windows-mgmt VM created by qvm-create-windows-qube/install.sh
# qvm-create-windows-qube will fetch the iso files from windows-mgmt to create windows VMs
qvm-volume resize windows-mgmt:private 20G
qvm-run windows-mgmt '/home/user/qvm-create-windows-qube/windows/isos/mido.sh win10x64-enterprise-ltsc-eval'

# Install qubes-windows-tools
sudo qubes-dom0-update --enablerepo qubes-dom0-current-testing --action=upgrade qubes-windows-tools
# Install version 4.1.69 due to qsb-091 https://www.qubes-os.org/news/2023/07/27/qsb-091/
sudo qubes-dom0-update --action=downgrade qubes-windows-tools

# Create a windows10 kuh
# Packages can be found at https://community.chocolatey.org/packages?q=office
# Creates a standalone windows 10 VM called work-win10
qvm-create-windows-qube \
    --netvm sys-firewall \
    --optimize \
    --spyless \
    --packages steam,firefox,notepadplusplus,office365proplus \
    --iso win10x64-enterprise-ltsc-eval.iso \
    --answer-file win10x64-enterprise-ltsc-eval.xml \
    work-win10

qvm-create-windows-qube \
    --template \
    --netvm sys-firewall \
    --optimize \
    --spyless \
    --packages firefox,notepadplusplus \
    --iso win10x64-enterprise-ltsc-eval.iso \
    --answer-file win10x64-enterprise-ltsc-eval.xml \
    tpl-win10


# Fix firewall? When I tried "the internet" wans't working without this
qvm-firewall work-win10 reset
qvm-firewall work-win10 del --rule-no 0
qvm-firewall work-win10 add accept
qvm-firewall work-win10
# I edited line line 346 in qvm-create-windows-qube. This prevents that you have to open the firewall to download qubes os tools
# -airgap
# +echo airgap


# Remove
# qvm-shutdown --force --wait work-win10 && qvm-remove --force work-win10

user@dom0 ~ $ qvm-prefs work-win10 visible_ip
10.137.0.45

[user@sys-firewall ~]$ ip r | grep <windows-ip>
10.137.0.45 dev vif586.0 scope link metric 32166 linkdown

[user@sys-firewall ~]$ tcpdump -i vif586.0
