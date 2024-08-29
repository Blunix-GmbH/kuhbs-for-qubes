#!/bin/bash
#
# "Automatically" paste in Qubes OS with a i3 keybind

set -e -x



# Notify the user
notify-send "Pasting"

# I dont know why the sleep 1 is required, but without it it doesnt work
sleep 1

# Paste from Qubes copy buffer
xdotool key Control_L+Shift_L+v

# Middle mouse button works in termianls and everywhere else
/usr/bin/xdotool click 2
# CRTL + v does not work in terminals
#xdotool key Control_L+v
