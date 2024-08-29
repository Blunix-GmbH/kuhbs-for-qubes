#!/bin/bash
#
# Call this script with dmenu to start applications in a kuh
# This script starts a program inside VM by starting a graphical terminal which starts the executable, so you can see the executables output
#
# Usage: TARGET=sys-net-dns  COMMAND=/usr/bin/wireshark TITLE=h4x0r   TERMINAL_USER=root /home/user/kuhbs/scripts/i3-qvm-launch
#        TARGET=tool-browser COMMAND=/usr/bin/firefox   TITLE=browser DISPVM=1           /home/user/kuhbs/scripts/i3-qvm-launch

set -x

## VARIABLES

source /home/user/kuhbs/defaults.sh

# Target VM
TARGET="$TARGET"

# Command to run
COMMAND="$COMMAND"
if [[ -z "$TARGET" ]]; then
    echo "Variable \$TARGET is empty, aborting!"
    exit 1
elif [[ -z "$COMMAND" ]]; then
    echo "Variable \$COMMAND is empty, aborting!"
    exit 1
fi

# Terminal title
TITLE="${TITLE:=$TARGET___$COMMAND}"

# TERMINAL_USER to execute command as
TERMINAL_USER="${TERMINAL_USER:=TERMINAL_USER}"

# run in unnamed DisposableVM or not
if [[ "${DISPVM:=0}" == "1" ]]; then
    run_in_dispvm="--dispvm"
fi



# If there is no xterm installed we have to abort
if ! /usr/bin/qvm-run $TARGET "which xterm"; then
    echo "xterm not installed at $XTERM_PATH"
    exit 1

# Dont open a terminal in a terminal - use kuhbs terminal to open a terminal in the kuh
elif [[ "$COMMAND" == *"xfce4-terminal"* ]] || [[ "$COMMAND" == *"xterm"* ]] || [[ "$COMMAND" == "terminal" ]]; then
    #kuhbs terminal $TARGET "$TERMINAL_USER"
    /usr/bin/qvm-run --user "$TERMINAL_USER" $run_in_dispvm "$TARGET" "xfce4-terminal --hide-menubar --hide-borders --hide-toolbar --hide-scrollbar"

# Start the application in a terminal. If it fails run cat to keep the terminal open to read the debug output
else
    /usr/bin/qvm-run --user "$TERMINAL_USER" $run_in_dispvm "$TARGET" "$XTERM_COMMAND -bg lightblue -fg black -title \'$TITLE\' -e \"set -x; $COMMAND || cat\"" &

fi
