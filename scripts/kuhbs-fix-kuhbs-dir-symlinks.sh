#!/bin/bash
#
# Fix symlinks from setup-scripts/ to kuhbs/ dir


find /home/user/kuhbs/kuhbs -xtype l | while read line; do
  filename=$(echo $line | rev | cut -d '/' -f 1 | rev | cut -d '-' -f 2-)
  if test -f /home/user/kuhbs/setup-scripts/$filename; then
echo    ln -vsf /home/user/kuhbs/setup-scripts/$filename $line
  fi
done
