#!/bin/bash
#
# Run "tests": executes all possible kuhbs commands. Used to debug kuhbs and see if "everything is working"

set -e


# Reset this termials screen (deletes all previously printed messages in the terminal)
reset

# Run kuhbs create in multiple xterms to build all check kuhb's in parallel
parallel=false



# Run a command to check if it works
run_test_command() {

    # All remaining arguments are the bash command and its own arguments
    test_comment="$1"
    test_command="${@:2}"

    # Print the test comand very large
    cat << EOF
##################################################################################################
####    ${test_comment^^}
####    $test_command
##################################################################################################

EOF

    # Execute remaining arguments as its own command
    $test_command
    echo -e "\n\n\n"

}



# Check kuhbs arguments that are not related to a specific kuhb
run_test_command "list all defined kuhbs" kuhbs ls

# Iterate the possible kuhb types
# code: StandaloneVM
# deb-12: TemplateVM
# firefox: AppVM
# sys-net-nic: Named DispVM
# torbrowser: Unnamed DispVM
#
# TODO when creating a standalone VM the apt proxy settings are not setup even with qvm-service --enable fo updates-proxy-setup
# https://www.reddit.com/r/Qubes/comments/agyune/how_to_use_update_proxy_on_standalonevm/
#for check_run_vm_type in code deb-12 firefox sys-net-nic torbrowser; do
for check_run_vm_type in deb-12 firefox sys-net-nic torbrowser; do

    kuhb_name="checks/$check_run_vm_type"

    if [[ "$parallel" != "true" ]]; then

        run_test_command "remove kuhb" kuhbs remove $kuhb_name
        run_test_command "remove absent kuhb" kuhbs remove $kuhb_name
        run_test_command "create kuhb" kuhbs create $kuhb_name
#        run_test_command "backup kuhb" kuhbs backup $kuhb_name
#        run_test_command "restore kuhb" kuhbs restore $kuhb_name
        run_test_command "upgrade kuhb" kuhbs upgrade $kuhb_name

    else

        # Run this step in another terminal so all kuhb can be build in parallel
        commands="kuhbs show $kuhb_name && kuhbs remove $kuhb_name && kuhbs create $kuhb_name && kuhbs create $kuhb_name && kuhbs backup $kuhb_name && kuhbs restore $kuhb_name && kuhbs upgrade $kuhb_name; cat"
        xterm -title "kuhb checks/$check_run_vm_type" -bg black -fg white -fs 12 -fa DejaVuSansMono +sb -e "set -x; $commands" &

    fi


done

run_test_command "open a terminal on a kuh" kuhbs terminal app-checks-firefox root
run_test_command "xl stop a kuh, dump its memory and disks into /root/kuhbs-dump/" kuhbs dump app-checks-firefox
