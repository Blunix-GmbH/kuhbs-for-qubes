#!/bin/bash
#
# Setup all my kuhbs in individual xterm windows that each run one instance of `kuhbs create <kuhb>`

set -e


for kuhb_name in \
    airgap \
    cus \
    doc \
    chrome \
    surf \
    element \
    signal \
    mail \
    private \
; do

    # Run this step in another terminal so all kuhb can be build in parallel
    commands="kuhbs show $kuhb_name && kuhbs remove $kuhb_name && kuhbs create $kuhb_name; cat"
    xterm -title "kuhb $kuhb_name" -bg black -fg white -fs 12 -fa DejaVuSansMono +sb -e "set -x; $commands" &

done
