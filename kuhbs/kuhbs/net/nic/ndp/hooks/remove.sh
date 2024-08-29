#!/bin/bash
#
# Assign the pci usb card back to sys-usb

set -x -e



# Variables
pci_device="dom0:00_14.3"
detach_from=ndp-kuhbs-net-nic
attach_to=sys-net


# Check if its already attached
if qvm-pci | grep $pci_device | grep --quiet $attach_to; then
    echo "Already attached to $attach_to"
    exit 0
fi


# Detach from $detach_from
qvm-shutdown --wait --force $detach_from
qvm-pci detach $detach_from

# Attach to $attach_to
qvm-shutdown --wait --force $attach_to
qvm-pci attach $attach_to $pci_device --verbose --persistent
qvm-start $attach_to

# switch net-gateway
qvm-prefs ndp-kuhbs-net-gateway netvm sys-net
