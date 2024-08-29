#!/bin/bash
#
# Install kuhbs in dom0
#
# READ THIS SCRIPT BEFORE EXECUTING IT !!! AND REMOVE / MODIFY COMMANDS AS IT FITS YOUR NEEDS


set -e -x


# Update ~/.bashrc
cp -v templates/home/user/.bashrc /home/user/

# Upgrade dom0
sudo qubes-dom0-update

# Install templates
qvm-template install debian-12-minimal
qvm-template --enablerepo qubes-templates-community-testing install kali-core

# Set some prefs
qvm-prefs debian-12-minimal label green
qvm-prefs whonix-gateway-17 label green

# Install packages
sudo qubes-dom0-update \
    brightnessctl \
    cowsay \
    i3 \
    i3-settings-qubes \
    gnome-screenshot \
    gnome-terminal \
    acpi \
    git \
    strace \
    locate \
    zenity

# Update locate db
sudo updatedb

# Copy i3 config in place
mkdir -p /home/user/.config/i3/
cp -v templates/home/user/.config/i3/config /home/user/.config/i3/
cp -v templates/home/user/.config/i3/i3status.conf /home/user/.config/i3/

# Copy X11 config file for 144 dpi
#sudo cp -v templates/etc/X11/Xressources /etc/X11/Xressources

# Copy xfce4-terminal config file
mkdir -p /home/user/.config/xfce4/terminal/
cp -v templates/home/user/.config/xfce4/terminal/terminalrc /home/user/.config/xfce4/terminal/terminalrc

# Disable boot splash screen
sudo sed -i 's/ rhgb quiet//g' /etc/grub2-efi.cfg
sudo sed -i 's/ rhgb quiet//g' /etc/default/grub

# Fix i3 kicked out of session bug?
sed -i 's/^GRUB_CMDLINE_LINUX/GRUB_CMDLINE_LINUX="$GRUB_CMDLINE_LINUX rd.qubes.hide_all_usb nouveau.noaccel=1"' /etc/default/grub
sudo grub2-mkconfig -o /boot/efi/EFI/qubes/grub.cfg

# Symlink kuhbs executable to /usr/local/bin/kuhbs
ln -sf /home/user/kuhbs/scripts/kuhbs-executable /usr/local/bin/kuhbs

# Setup display power management
xfce4-settings-manager
