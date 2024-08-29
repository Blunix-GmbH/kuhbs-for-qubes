#!/bin/bash
#
# "Automatically" copy in Qubes OS with a i3 keybind

set -e -x



# Notify the user
notify-send "Copying"

# I dont know why the sleep 1 is required, but without it it doesnt work
sleep 1

# CRTL + c would abort things in terminals
#xdotool key Control_L+c

# CRTL + Shift + c to copy into Qubes copy buffer
/usr/bin/xdotool key Control_R+Shift_R+c
