# Restore the backups of a kuhb
kuhb_restore() {

    # Check if $BACKUP_VM_MOUNTPOINT is a mountpoint
    qvm-run --quiet --user root $BACKUP_VM "mountpoint $BACKUP_VM_MOUNTPOINT" || log $BACKUP_VM error "$BACKUP_VM_MOUNTPOINT is not mounted"
    # Check if /mnt/kuhbs-backup (BACKUP_VM_BACKUP_PATH from defaults.sh) exists
    qvm-run --quiet --user root $BACKUP_VM "test -d $BACKUP_VM_BACKUP_PATH" || log $BACKUP_VM error "backup destination $BACKUP_VM_BACKUP_PATH/ is not a directory"

    # Backup StandaloneVM
    if [[ "$KUHB_TYPE" == "sta" ]]; then
        if ! verify_kuh_exists "sta-${KUHB_NAME}"; then
            log "sta-${KUHB_NAME}" warn "kuh does not exist but should be the only VM in this kuhb"
        elif ! verify_kuh_backup_exists "sta-${KUHB_NAME}"; then
            log "sta-${KUHB_NAME}" warn "no backups found in $BACKUP_VM_BACKUP_PATH/*/sta-${KUHB_NAME}/backup.tar.gz"
        else
            kuh_backup_restore "sta-${KUHB_NAME}"
        fi
    fi

    # Backup TemplateVM
    if [[ "$KUHB_TYPE" =~ ^(tpl|app|udp|ndp)$ ]]; then
        if ! verify_kuh_exists "tpl-${KUHB_NAME}"; then
            log "tpl-${KUHB_NAME}" warn "kuh does not exist but is part of this kuhb"
        elif ! verify_kuh_backup_exists "tpl-${KUHB_NAME}"; then
            log "tpl-${KUHB_NAME}" warn "no backups found in $BACKUP_VM_BACKUP_PATH/*/tpl-${KUHB_NAME}/backup.tar.gz"
        else
            kuh_backup_restore "tpl-${KUHB_NAME}"
        fi
    fi

    # Backup AppVM
    if [[ "$KUHB_TYPE" =~ ^(app|udp|ndp)$ ]]; then
        if ! verify_kuh_exists "app-${KUHB_NAME}"; then
            log "app-${KUHB_NAME}" warn "kuh does not exist but is part of this kuhb"
        elif ! verify_kuh_backup_exists "app-${KUHB_NAME}"; then
            log "app-${KUHB_NAME}" warn "no backups found in $BACKUP_VM_BACKUP_PATH/*/app-${KUHB_NAME}/backup.tar.gz"
        else
            kuh_backup_restore "app-${KUHB_NAME}"
        fi
    fi

}
