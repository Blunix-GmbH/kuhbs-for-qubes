#!/bin/bash
#
# Run i3wm, kuhbs and general session initialization commands

set -e -x



# Set default brightness
brightnessctl s 75

# Switch to kuhbs workspace
i3-msg workspace 11

# Set display resolution
xrandr -s 1920x1080

# Wait for network (may run at boot)
while ! qvm-run ndp-kuhbs-net-nic 'ping -c 1 8.8.4.4 2>/dev/null'; do
    echo "kuhbs-net-nic: unable to ping 8.8.8.8, sleeping for 5 seconds..."
    sleep 5
done


# Upgrade all VMs
kuhbs upgrade-all


read -p "PRESS ENTER WHEN ALL UPGRADES ARE FINISHED TO START DEFAULT APPLICATIONS"


# Start default launchers
default_launchers="airgap-terminal
surf-librewolf
mail-terminal
blunix-chromium
cus-chromium
element-element
signal-signal"

for default_launcher in $default_launchers; do
    echo "Executing script /home/user/.kuhbs/launchers/$default_launcher"
    /home/user/.kuhbs/launchers/$default_launcher &
done


# Wait for user to acknowledge progress and close terminal
echo
read -p "PRESS ENTER TO CLOSE THIS TERMINAL"
exit
