#!/bin/bash
#
# Setup launchers for the flatpaks

set -x -e



# Setup flatpak launcher for librewolf browser
echo 'flatpak run io.gitlab.librewolf-community && sudo shutdown -h now || cat' > /usr/bin/kuhbs-librewolf
chmod 755 /usr/bin/kuhbs-librewolf
ln -sf /usr/bin/kuhbs-librewolf /etc/alternatives/x-www-browser

# Setup flatpak launcher for chromium
echo 'flatpak run io.github.ungoogled_software.ungoogled_chromium && sudo shutdown -h now || cat' > /usr/bin/kuhbs-chromium
chmod 755 /usr/bin/kuhbs-chromium

# Setup flatpak launcher for regular firefox
echo 'flatpak run org.mozilla.firefox && sudo shutdown -h now || cat' > /usr/bin/kuhbs-firefox
chmod 755 /usr/bin/kuhbs-firefox
