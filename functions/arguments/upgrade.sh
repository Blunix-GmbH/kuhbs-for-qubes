# Upgrade a kuhb
kuhb_upgrade() {

    # Install upgrades for StandaloneVMs, TemplateVMs and AppVMs
    for kuh_type in sta tpl app ndp; do

        # Parse arguments
        local kuh_name="${kuh_type}-${KUHB_NAME}"
        local kuh_path="$KUHB_PATH/$kuh_type"

        # Only upgrade kuh if its relevant to the KUHB_TYPE
        [[ "$kuh_type" == "sta" ]] && [[ "$KUHB_TYPE" != "sta" ]] && continue
        [[ "$kuh_type" == "tpl" ]] && [[ "$KUHB_TYPE" == "sta" ]] && continue
        [[ "$kuh_type" == "app" ]] && [[ "$KUHB_TYPE" =~ (sta|tpl) ]] && continue
        [[ "$kuh_type" == "ndp" ]] && [[ "$KUHB_TYPE" != "ndp" ]] && continue

        # Verify the kuh exists
        ! [[ "$kuh_type" =~ (ndp|udp) ]] && ! verify_kuh_exists "$kuh_name" && log "$kuh_name" error "kuh does not exist"

        # Save the running state of the kuh so if it was shutdown before we shut it down again after the backup is completed
        if [[ "$kuh_type" != "udp" ]]; then
            local qube_running_state=$(qvm-ls --fields=state --raw-data "$kuh_name")
        else
            # We can't know the name of UDPs (disp0123)
            local qube_running_state=Halted
        fi

        # Upgrade apt packages
        if [[ "$kuh_type" =~ (sta|tpl) ]]; then
            kuh_script "$kuh_name" root "$KUHBS_COMMON_SCRIPTS_PATH/apt-update.sh"
        fi

        # Run update hook scripts
        if [[ "$kuh_type" =~ (sta|tpl|app) ]]; then
            if [[ -f "$kuh_path/hooks/update.sh" ]]; then
                log "$kuh_name" info "executing upgrade hook script"
                kuh_script "$kuh_name" root "$kuh_path/hooks/update.sh"
            else
                log "$kuh_name" info "no upgrade hook script found at $kuh_path/hooks/update.sh"
            fi
        fi


        # Notify the user about restarting Unnamed DisposableVMs
        if [[ "$KUHB_TYPE" == "udp" ]]; then
            log "app-${KUHB_NAME}" info "Please manually restart all Unnamed Disposable VMs based on this AppVM"

        # If the kuh was running before, restart it
        elif [[ "$qube_running_state" == "Running" ]]; then
            log "$kuh_name" info "restarting kuh as it was running before"
            kuhbs_run_dom0 qvm-shutdown $qvm_verbose --force --wait "$kuh_name"
            kuhbs_run_dom0 qvm-start "$kuh_name"

        # Shutdown all other if they were started by the upgrade process
        elif qvm-check --quiet --running "$kuh_name"; then
            log "$kuh_name" info "Shutting down"
            kuhbs_run_dom0 qvm-shutdown $qvm_verbose --force --wait "$kuh_name"

        else
            log "$kuh_name" info "Halted"

        fi

    done
}


# Upgrade all defined and present kuhbs
kuhbs_upgrade_all() {

    # Iterate all defined kuhb's that have a config.sh
    # Ignore "checks" kuhb
    find "$KUHBS_CONFIG_PATH_KUHBS" -type f -name config.sh | grep -v checks | while read line; do

        # Extract the name of the kuhb
        local upgrade_kuhb_name=$(echo "$line" | sed -e 's@/config.sh@@g' -e "s@$KUHBS_CONFIG_PATH_KUHBS/@@g")
        local upgrade_kuhb_name_dash="$(echo $upgrade_kuhb_name | sed 's@/@-@g')"
        local upgrade_kuhb_type="$(grep KUHB_TYPE $line | cut -d '=' -f 2)"

        # Verify this kuhb exists
        if ! verify_kuhb_exists "$upgrade_kuhb_name_dash" "$upgrade_kuhb_type"; then
            log kuhbs warn "skipping kuhb $upgrade_kuhb_name as it is not created"
            continue
        fi

        # Launch a terminal that upgrades this kuhb
        log kuhbs info "opening terminal to upgrade the kuhb $upgrade_kuhb_name"
        $XTERM_COMMAND -title "upgrade $upgrade_kuhb_name" -e "set -x; kuhbs upgrade $upgrade_kuhb_name; read -p 'Press anykey to close this terminal' wait_key" &

    done
}
