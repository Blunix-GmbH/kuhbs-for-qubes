# List a specific kuhb
kuhb_show() {

    log kuhbs info "kuhb ${KUHB_NAME} (type ${KUHB_TYPE})"

    # List StandaloneVM
    if [[ "$KUHB_TYPE" == "sta" ]]; then
        if verify_kuh_exists "sta-${KUHB_NAME}"; then
            if qvm-check --quiet --running "sta-${KUHB_NAME}"; then
                log "sta-${KUHB_NAME}" info "running"
            else
                log "sta-${KUHB_NAME}" info "shutdown"
            fi
        else
            log "sta-${KUHB_NAME}" warn "absent"
        fi
        return

    # List TemplateVM
    else
        if verify_kuh_exists "tpl-${KUHB_NAME}"; then
            if qvm-check --quiet --running "tpl-${KUHB_NAME}"; then
                log "tpl-${KUHB_NAME}" warn "running"
            else
                log "tpl-${KUHB_NAME}" info "shutdown"
            fi
        else
            log "tpl-${KUHB_NAME}" warn "absent"
        fi

    fi

    # List AppVM
    if [[ "$KUHB_TYPE" == @(app|ndp|udp) ]]; then
        if verify_kuh_exists "app-${KUHB_NAME}"; then
            if qvm-check --quiet --running "app-${KUHB_NAME}"; then
                [[ "$KUHB_TYPE" == @(ndp|udp) ]] && log "app-${KUHB_NAME}" warn "running" || log "app-${KUHB_NAME}" info "running"
            else
                log "app-${KUHB_NAME}" info "shutdown"
            fi
        else
            log "app-${KUHB_NAME}" warn "absent"
        fi

    fi

    # List named DisposableVM
    if [[ "$KUHB_TYPE" == "ndp" ]]; then
        if verify_kuh_exists "ndp-${KUHB_NAME}"; then
            if qvm-check --quiet --running "ndp-${KUHB_NAME}"; then
                log "ndp-${KUHB_NAME}" info "running"
            else
                log "ndp-${KUHB_NAME}" info "shutdown"
            fi
        else
            log "ndp-${KUHB_NAME}" warn "absent"
        fi
    fi

}
