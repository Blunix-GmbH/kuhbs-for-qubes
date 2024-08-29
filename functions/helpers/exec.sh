# This simply runs any command in dom0 with BASH's "set -x". This is supposed to provide clarity about which bash commands are executed in dom0.
kuhbs_run_dom0() {
    set -x
    "$@"
    { set +x; } 2>/dev/null
    # If debug mode is enabled, set +x would disable debug mode, hence enabling it again
    if [[ "$debug" == "true" ]]; then set -x; fi
}



# Copy a script from dom0 to a kuh and execute it
kuh_script() {

    # Parse arguments
    local -r script_kuh_name="$1"
    local -r kuh_script_user="$2"
    local -r kuh_script="$3"
    local -r kuh_script_basename=$(basename "$kuh_script")

    # Skip if KUHBS_CHECK_MODE is set to true in defaults.sh
    if [[ "$KUHBS_CHECK_MODE" == "true" ]]; then
        log "$script_kuh_name" info "NOT EXECUTING SCRIPT $kuh_script BECAUSE KUHBS_CHECK_MODE IS SET TO true IN defaults.sh"
        return 0
    else
        log "$script_kuh_name" info "executing script $kuh_script"
    fi

    # Remove script and kuhbs-run-script.sh if present
    if ! [[ "$verbose" == "false" ]]; then
        kuhbs_run_dom0 qvm-run --quiet --user root "$script_kuh_name" "rm -f /home/user/QubesIncoming/dom0/kuhbs-run-script.sh /home/user/QubesIncoming/dom0/$kuh_script_basename"
    else
        qvm-run --quiet --user root "$script_kuh_name" "rm -f /home/user/QubesIncoming/dom0/kuhbs-run-script.sh /home/user/QubesIncoming/dom0/$kuh_script_basename"
    fi
    # Copy kuhbs-run-script.sh and script to VM
    kuhbs_run_dom0 qvm-copy-to-vm "$script_kuh_name" "$KUHBS_BASE_PATH_SCRIPTS/kuhbs-run-script.sh" "$kuh_script"

    if ! [[ "$verbose" == "false" ]]; then
        kuhbs_run_dom0 qvm-run --quiet --user root "$script_kuh_name" "chmod 500 /home/user/QubesIncoming/dom0/kuhbs-run-script.sh /home/user/QubesIncoming/dom0/$kuh_script_basename"
    else
        qvm-run --quiet --user root "$script_kuh_name" "chmod 500 /home/user/QubesIncoming/dom0/kuhbs-run-script.sh /home/user/QubesIncoming/dom0/$kuh_script_basename"
    fi

    # Graphical terminals like xterm do not return the exit status of the command they execute, example:
    # xterm -e /bin/false; echo $?
    # 0
    # Because of this, we need to store the exit status somewhere so we can evaluate it
    local -r exit_status_file="/tmp/.kuhbs-script-exit-status-$(tr -dc A-Za-z0-9 </dev/urandom | head -c 16)"

    # Setup i3wm to split the screen for new windows
    i3-msg --quiet split "$I3_SPLIT_METHOD"

    # Run in xterm
    if qvm-run --quiet --user root "$script_kuh_name" "which xterm" >/dev/null 2>&1; then
        kuhbs_run_dom0 qvm-run --quiet --user "$kuh_script_user" "$script_kuh_name" \
            "$XTERM_COMMAND -title script_${kuh_script} -e /home/user/QubesIncoming/dom0/kuhbs-run-script.sh $exit_status_file /home/user/QubesIncoming/dom0/$kuh_script_basename"

    # Abort if we can't find a graphical terminal emulator
    else
        log "$script_kuh_name" error "xterm is not installed"
    fi

    # Transfer the scripts exit status to dom0 by executing the exit_status_file as a script - it will just exit with the exit status of the script that we ran above
    # We need to temporarily disable set -e (abort the script on all errors) to allow this command to fail
    set +e
    qvm-run --quiet --user root "$script_kuh_name" "$exit_status_file"
    script_exit_status="$?"
    set -e
    if [[ "$script_exit_status" == "0" ]]; then
        log "$script_kuh_name" verbose "script completed with exit status $script_exit_status"
    else
        log "$script_kuh_name" error "script aborted with exit status $script_exit_status"
    fi

    # Remove scripts and exit status file
    if ! [[ "$verbose" == "false" ]]; then
        kuhbs_run_dom0 qvm-run --quiet --user root "$script_kuh_name" "rm -f /home/user/QubesIncoming/dom0/kuhbs-run-script.sh /home/user/QubesIncoming/dom0/$kuh_script_basename $exit_status_file"
    else
        qvm-run --quiet --user root "$script_kuh_name" "rm -f /home/user/QubesIncoming/dom0/kuhbs-run-script.sh /home/user/QubesIncoming/dom0/$kuh_script_basename $exit_status_file"
    fi

}



# Execute every script in a given directory
kuh_run_scripts_dir() {

    local -r scripts_dir_kuh_name="$1"
    local -r kuh_path="$KUHB_PATH/$kuh_type"
    local -r scripts_dir="$2"

    # Copy template directories from kuh scripts
    if [[ -d "$kuh_path/templates" ]]; then
        kuh_copy "$scripts_dir_kuh_name" "$kuh_path/templates"
        kuhbs_run_dom0 qvm-run --quiet --user root "$scripts_dir_kuh_name" "mv /home/user/QubesIncoming/dom0/templates /home/user/QubesIncoming/dom0/kuh-templates"
    else
        log "$scripts_dir_kuh_name" verbose "not copying absent $kuh_path/templates"
    fi

    # Copy templates from common scripts
    if [[ -d "$KUHBS_COMMON_SCRIPTS_PATH/templates" ]]; then
        kuh_copy "$scripts_dir_kuh_name" "$KUHBS_COMMON_SCRIPTS_PATH/templates"
        kuhbs_run_dom0 qvm-run --quiet --user root "$scripts_dir_kuh_name" "mv /home/user/QubesIncoming/dom0/templates /home/user/QubesIncoming/dom0/common-templates"
    else
        log "$scripts_dir_kuh_name" info "not copying $KUHBS_COMMON_SCRIPTS_PATH/templates as it is absent"
    fi

    # Combine all scripts into one script
    tmp_script="$(mktemp --suffix=kuhbs-script)"
    log "$scripts_dir_kuh_name" info "combining the scripts in $scripts_dir/*.sh into a single script $tmp_script"
    echo -e '#!/bin/bash\nset -e -x\n' > "$tmp_script"
    find -L "$scripts_dir" -type f | sort --numeric-sort | while read script_path; do
        cat "$script_path" | sed 's@#!/bin/bash@@g' >> "$tmp_script"
    done

    # Execute the script
    # the </dev/null at the end prevents kuh_script from reading the stdin of the loop and thereby breaking the loop
    kuh_script "$scripts_dir_kuh_name" root "$tmp_script" </dev/null
    kuhbs_run_dom0 rm "$tmp_script"

    # Remove QubesIncoming directories
    log "$scripts_dir_kuh_name" info "deleting directory /home/user/QubesIncoming/"
    kuhbs_run_dom0 qvm-run --quiet --user root "$scripts_dir_kuh_name" "rm -rf /home/user/QubesIncoming/"

}


# Execute a command in a VM by writing the command into a tmpfile and using kuh_script to run it like a script
kuh_execute_command() {
    local -r run_kuh_name="$1"
    local -r kuh_run_user="$2"
    local -r kuh_run_command="${@:3}"
    local -r kuhbs_one_line_exec_script=$(mktemp /tmp/tmp.kuhbs.XXXXXX)
    # using set -x here doesnt look nice as the > isn't formatted nicly
    echo "+ echo \"$kuh_run_command\" > $kuhbs_one_line_exec_script"
    echo "set -x; $kuh_run_command" > $kuhbs_one_line_exec_script
    kuh_script $run_kuh_name $kuh_run_user $kuhbs_one_line_exec_script
    kuhbs_run_dom0 rm -f $kuhbs_one_line_exec_script
    # Garbage collect old tmp files?
    #find /tmp/tmp.kuhbs.* -mmin +59 -delete
}
