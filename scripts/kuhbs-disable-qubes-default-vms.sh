#!/bin/bash

set -x

qvm-shutdown sys-usb
qvm-shutdown sys-whonix
qvm-shutdown sys-firewall
qvm-shutdown sys-net
qvm-prefs sys-usb autostart false
qvm-prefs sys-whonix autostart false
qvm-prefs sys-firewall autostart false
qvm-prefs sys-net autostart false

