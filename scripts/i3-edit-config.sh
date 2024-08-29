#!/bin/bash
#
# Spawn a xfce4-terminal in dom0 that opens an my_editor for /home/user/.config/i3/config

set -e -x


# Your favorite editor. Popular choices:
# /usr/bin/vi
# /usr/bin/vim
# Run `apropos editor` to see more choices
my_editor=/usr/bin/nano


# Edit config files relevant to i3wm
xfce4-terminal --hide-menubar --hide-borders --hide-toolbar --hide-scrollbar --execute $my_editor /home/user/.config/i3/config
xfce4-terminal --hide-menubar --hide-borders --hide-toolbar --hide-scrollbar --execute $my_editor /home/user/.config/i3/i3status.conf
