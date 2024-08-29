
# List VMs to see if they are present or not
kuhbs_ls() {

    vm_list="$(qvm-ls --fields name,state)"

    # Iterate all defined kuhbs that have a config.sh
    find "$KUHBS_CONFIG_PATH_KUHBS" -type f -name config.sh | while read line; do

        # Extract the kuhb type
        KUHB_TYPE=$(grep KUHB_TYPE "$line" | cut -d '=' -f 2)
        # Setup KUHB_NAME
        local KUHB_NAME=$(echo "$line" | sed -e "s@$KUHBS_CONFIG_PATH_KUHBS/@@g;s@/config.sh@@g" -e 's@/@-@g')
        # Log which kuhb is being processed
        log kuhbs info "kuhb: $KUHB_NAME of type $KUHB_TYPE"

        # List StandaloneVM
        if [[ "$KUHB_TYPE" == "sta" ]]; then
            if [[ "$vm_list" =~ "sta-${KUHB_NAME}" ]]; then
                vm_state=$(echo "$vm_list" | grep "^sta-${KUHB_NAME} " | awk '{print $2}')
                log "sta-${KUHB_NAME}" info "$vm_state"
            else
                log "sta-${KUHB_NAME}" warn "absent"
            fi
            return

        # List TemplateVM
        else
            if [[ "$vm_list" =~ "tpl-${KUHB_NAME}" ]]; then
                vm_state=$(echo "$vm_list" | grep "^tpl-${KUHB_NAME} " | awk '{print $2}')
                log "tpl-${KUHB_NAME}" info "$vm_state"
            else
                log "tpl-${KUHB_NAME}" warn "absent"
            fi
        fi

        # List AppVM
        if [[ "$KUHB_TYPE" == @(app|ndp|udp) ]]; then
            if [[ "$vm_list" =~ "app-${KUHB_NAME}" ]]; then
                vm_state=$(echo "$vm_list" | grep "^app-${KUHB_NAME} " | awk '{print $2}')
                if [[ "$KUHB_TYPE" == @(ndp|udp) ]] && [[ "$vm_state" != "Halted" ]]; then
                    log "app-${KUHB_NAME}" warn "$vm_state"
                else
                    log "app-${KUHB_NAME}" info "$vm_state"
                fi
            else
                log "app-${KUHB_NAME}" warn "absent"
            fi

        fi

        # List named DisposableVM
        if [[ "$KUHB_TYPE" == "ndp" ]]; then
            if [[ "$vm_list" =~ "ndp-${KUHB_NAME}" ]]; then
                vm_state=$(echo "$vm_list" | grep "^ndp-${KUHB_NAME} " | awk '{print $2}')
                log "ndp-${KUHB_NAME}" info "$vm_state"
            else
                log "ndp-${KUHB_NAME}" warn "absent"
            fi
        fi


        # Print newline for better readable output
        echo

    done

}
