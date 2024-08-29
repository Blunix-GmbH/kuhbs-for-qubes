#!/bin/bash
#
# Create launcher for signal

set -x -e


# Create a launcher that automatically shuts down the VM when signal closes with exit status 0 and otherwise keeps the terminal open to read the debug ouptut using a cat
echo '/usr/bin/signal-desktop && sudo shutdown -h now || cat' | tee /usr/bin/kuhbs-signal
chmod 755 /usr/bin/kuhbs-signal
