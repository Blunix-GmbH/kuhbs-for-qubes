#!/bin/bash
#
# Wrapper to run another script in a VM



# Path to store the exit status
declare -r exit_status_file=$1

# Path to script to run
declare -r run_script=$2

# Execute the script

/bin/bash -c "set -e -x; $run_script"
declare -r run_exit_status=$?

# Save the exit status
umask 0277
# Create a script that exits with the same exit status as teh script we ran
# It is then executed with qvm-run and we can "transfer" the exit status to dom0
echo "exit $run_exit_status" > $exit_status_file
chmod 500 $exit_status_file

# Keep the shell open for 5 seconds if the exit status was 0
if [[ "$run_exit_status" == "0" ]]; then
# Communicate exit status to the user
    echo -e "\n\nExit status: $run_exit_status"
    if read -t 5 -p "Press ENTER within 5 seconds to keep the shell open, or CRTL + C to close it immediately"; then
        echo "Press CRTL + c to close this shell"
        cat
    fi
    exit 0

# Keep the shell open permanently if the exist status was not 0
else
    echo -e "\n\nNON ZERO EXIT STATUS: $run_exit_status"
    read -p "This terminal is kept open until you press ENTER"
    exit $run_exit_status

fi
