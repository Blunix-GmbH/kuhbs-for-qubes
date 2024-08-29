#!/bin/bash
#
# "reinstall" kuhbs


set -e -x

iso_download_vm=disp2434
usb_vm=ndp-kuhbs-usb
usb_device=sda


# Download Qubes iso
#qvm-run $iso_download_vm "wget https://mirrors.edge.kernel.org/qubes/iso/Qubes-R4.2.2-x86_64.iso"

# Copy to usb vm
#echo "Select \"$usb_vm\" as destination!"
#qvm-run $iso_download_vm "qvm-copy Qubes-R4.2.2-x86_64.iso"

# Shutdown iso download vm
qvm-shutdown $iso_download_vm

# Shread device
#read -p "Shred the device $usb_vm:$usb_device (Y/n): " shred_question
#    if 

# dd to usb device
qvm-run -u root $usb_vm "dd if=/home/user/QubesIncoming/$iso_download_vm/Qubes-R4.2.2-x86_64.iso of=/dev/$usb_device"

# Create filesystem
echo 'qvm-run $usb_vm "parted"'
