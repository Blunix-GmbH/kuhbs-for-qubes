#!/bin/bash
#
# Remove netvm pref after packages have been downloaded

set -e -x
set -o nounset

qvm-prefs tpl-kuhbs-usb netvm None
