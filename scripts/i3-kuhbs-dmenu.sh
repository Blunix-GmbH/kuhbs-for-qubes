#!/bin/bash

# Source kuhbs defaults.sh to get the path for the launchers
source /home/user/kuhbs/defaults.sh

# Use dmenu to let the user select the name of the launcher
launcher_name=$(ls $KUHBS_CONFIG_PATH_LAUNCHERS/ | dmenu -f -i -nb blue -nf white -sb '#66CC00' -sf black)

# Execute the launcher
$KUHBS_CONFIG_PATH_LAUNCHERS/$launcher_name

