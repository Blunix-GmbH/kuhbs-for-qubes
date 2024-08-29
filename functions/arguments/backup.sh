# Create a backup of a specific kuhb
kuhb_backup() {

    # Check if $BACKUP_VM_MOUNTPOINT is a mountpoint
    qvm-run --quiet --user root $BACKUP_VM "mountpoint $BACKUP_VM_MOUNTPOINT" || log $BACKUP_VM error "$BACKUP_VM_MOUNTPOINT is not mounted, mount the USB backup device or check the \"backup\" settings in kuhbs/defaults.sh"
    # Check if /mnt/kuhbs-backup (BACKUP_VM_BACKUP_PATH from defaults.sh) exists
    if ! qvm-run --quiet --user root $BACKUP_VM "test -d $BACKUP_VM_BACKUP_PATH"; then
        log $BACKUP_VM error "creating backup destination directory $BACKUP_VM_BACKUP_PATH/"
    fi

    # Backup StandaloneVM
    if [[ "$KUHB_TYPE" == "sta" ]]; then
        if ! verify_kuh_exists "sta-${KUHB_NAME}"; then
            log "sta-${KUHB_NAME}" warn "kuh does not exist but should be the only VM in this kuhb"
        elif [[ -z "${STA_BACKUP_PATHS+x}" ]]; then
            log "sta-${KUHB_NAME}" warn "not creating backup because STA_BACKUP_PATHS is not defined in config.sh"
        else
            kuh_backup "sta-${KUHB_NAME}" "${STA_BACKUP_PATHS[@]}"
        fi
    fi

    # Backup TemplateVM
    if [[ "$KUHB_TYPE" =~ ^(tpl|app|ndp|udp)$ ]]; then
        if ! verify_kuh_exists "tpl-${KUHB_NAME}"; then
            log "tpl-${KUHB_NAME}" warn "kuh does not exist but should be part of this kuhb"
        elif [[ -z "${TPL_BACKUP_PATHS+x}" ]]; then
            log "tpl-${KUHB_NAME}" warn "not creating backup because TPL_BACKUP_PATHS is not defined in config.sh"
        else
            kuh_backup "tpl-${KUHB_NAME}" "${TPL_BACKUP_PATHS[@]}"
        fi
    fi

    # Backup AppVM
    if [[ "$KUHB_TYPE" =~ ^(app|ndp|udp)$ ]]; then
        if ! verify_kuh_exists "app-${KUHB_NAME}"; then
            log "app-${KUHB_NAME}" warn "kuh does not exist but should be part of this kuhb"
        elif [[ -z "${APP_BACKUP_PATHS+x}" ]]; then
            log "app-${KUHB_NAME}" warn "not creating backup because APP_BACKUP_PATHS is not defined in config.sh"
        else
            kuh_backup "app-${KUHB_NAME}" "${APP_BACKUP_PATHS[@]}"
        fi
    fi

}


kuhbs_backup_all() {
    # Iterate all defined kuhb's that have a config.sh
    # Ignore "checks" kuhb's
    find "$KUHBS_CONFIG_PATH_KUHBS" -type f -name config.sh | grep -v checks | while read line; do

        # Extract the name of the kuhb
        local backup_kuhb_name=$(echo "$line" | sed -e 's@/config.sh@@g' -e "s@$KUHBS_CONFIG_PATH_KUHBS/@@g")
        local backup_kuhb_name_dash="$(echo $backup_kuhb_name | sed 's@/@-@g')"
        local backup_kuhb_type="$(grep KUHB_TYPE $line | cut -d '=' -f 2)"

        # Verify this kuhb exists
        if ! verify_kuhb_exists "$backup_kuhb_name_dash" "$backup_kuhb_type"; then
            log kuhbs warn "skipping kuhb $backup_kuhb_name as it is not created"
            continue
        fi

        # Launch a terminal that backups this kuhb
        log kuhbs info "opening terminal to backup the kuhb $backup_kuhb_name"
        $XTERM_COMMAND -title "backup $backup_kuhb_name" -e "set -x; kuhbs backup $backup_kuhb_name; read -p 'Press anykey to close this terminal' wait_key" &

    done
}
