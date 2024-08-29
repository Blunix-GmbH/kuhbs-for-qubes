# Create a backup of a kuh
kuh_backup() {

    local -r backup_kuh_name="$1"
    local -r backup_paths="${*:2}"
    local -r current_date=$(date "+%m-%d-%y")

    # Save the running state of the kuh so if it was shutdown before we shut it down again after the backup is completed
    local qube_running_state=$(qvm-ls --fields=state --raw-data "$backup_kuh_name")

    # Create backup of all files listed in $backup_paths
    log "$backup_kuh_name" info "creating backup of $backup_paths"
    kuh_execute_command "$backup_kuh_name" root "tar cvzf /rw/backup.tar.gz $backup_paths"
    log "$BACKUP_VM" info "creating backup directory $BACKUP_VM_BACKUP_PATH/$current_date/$backup_kuh_name/"
    kuhbs_run_dom0 qvm-run --quiet --user root "$BACKUP_VM" "mkdir -vp $BACKUP_VM_BACKUP_PATH/$current_date/$backup_kuh_name/"

    # Copy to BACKUP_VM
    # Use the insecure --pass-io if the user explicitly enabled it in defaults.sh
    if [[ "$BACKUP_CREATE_INSECURE_COPY" == "true" ]]; then
        log dom0 warn "you have set BACKUP_CREATE_INSECURE_COPY=true in kuhbs/defaults.sh, using insecure but automatic method of copying the backup file"
        kuhbs_run_dom0 qvm-run --quiet --user root "$BACKUP_VM" "mkdir -p /home/user/QubesIncoming/$backup_kuh_name/"
        # set -x does not display pipes very readable
        echo "+ qvm-run --pass-io --user root $backup_kuh_name \"cat /rw/backup.tar.gz\" | qvm-run --pass-io --user root $BACKUP_VM \"cat - > $BACKUP_VM_BACKUP_PATH/$current_date/$backup_kuh_name/backup.tar.gz"
        qvm-run --pass-io --user root "$backup_kuh_name" "cat /rw/backup.tar.gz" | qvm-run --pass-io --user root "$BACKUP_VM" "cat - > $BACKUP_VM_BACKUP_PATH/$current_date/$backup_kuh_name/backup.tar.gz"

    # Otherwise use the secure qvm-copy
    else
        log "$backup_kuh_name" info "select this destination VM in the graphical copy dialogue: $BACKUP_VM"
        kuhbs_run_dom0 qvm-run --quiet --user root "$backup_kuh_name" "qvm-copy /rw/backup.tar.gz"
        log "$BACKUP_VM" info "copying backup file to $BACKUP_VM_BACKUP_PATH/$current_date/$backup_kuh_name/"
        kuhbs_run_dom0 qvm-run --quiet --user root "$BACKUP_VM" "cp -v /home/user/QubesIncoming/$backup_kuh_name/backup.tar.gz $BACKUP_VM_BACKUP_PATH/$current_date/$backup_kuh_name/backup.tar.gz"
        # Overwrite and delete backup on backup VM
        log "$BACKUP_VM" info "overwriting restored backup file with random data and deleting"
        kuh_execute_command "$BACKUP_VM" root "shred --iterations 3 --remove --force --verbose /home/user/QubesIncoming/$backup_kuh_name/backup.tar.gz"

    fi

    # Overwrite and delete backup on source VM
    log "$backup_kuh_name" info "overwriting backup file on backed up VM with random data and deleting"
    kuh_execute_command "$backup_kuh_name" root "shred --iterations 3 --remove --force $qvm_verbose /rw/backup.tar.gz"

    # Shutdown the kuh again if it was not running before
    if [[ "$qube_running_state" != "Running" ]]; then
        log "$backup_kuh_name" info "kuh was shutdown when we started, shutting down again"
        kuhbs_run_dom0 qvm-shutdown $qvm_verbose --force --wait "$backup_kuh_name"
    fi
}



# Select which backup to restore
kuh_show_backup_date() {
    kuh_execute_command "$BACKUP_VM" root "find $BACKUP_VM_BACKUP_PATH/*/$backup_date_kuh_name/backup.tar.gz -type f | sed -e 's@$BACKUP_VM_BACKUP_PATH/@@g' -e 's@/$backup_date_kuh_name/backup.tar.gz@@g'; sleep 10"
}



# Restore a backup of a kuh
kuh_backup_restore() {

    # Check if /mnt/kuhbs-backup (BACKUP_VM_BACKUP_PATH from defaults.sh) exists
    qvm-run --quiet --user root $BACKUP_VM "test -d $BACKUP_VM_BACKUP_PATH" || log $BACKUP_VM error "No $BACKUP_VM_BACKUP_PATH/ directory found, is the backup media mounted?"

    local -r backup_restore_kuh_name="$1"

    # Save the running state of the kuh so if it was shutdown before we shut it down again after the backup is completed
    local -r qube_running_state=$(qvm-ls --fields=state --raw-data "$backup_restore_kuh_name")

    # Check if any backups are present
    if ! verify_kuh_backup_exists "$backup_restore_kuh_name"; then
        log "$backup_restore_kuh_name" info "no backups found at $BACKUP_VM_BACKUP_PATH/*/$backup_restore_kuh_name/backup.tar.gz"
        return 0
    fi

    # Pick a specific backup to restore
    log "$backup_restore_kuh_name" info "restoring backups, pick a backup date:"
    kuh_show_backup_date "$backup_restore_kuh_name"
    local backup_date=false
    local loop_count=0
    until qvm-run --quiet --user root "$BACKUP_VM" "ls $BACKUP_VM_BACKUP_PATH/$backup_date/$backup_restore_kuh_name/backup.tar.gz" >/dev/null 2>&1; do
        if [[ "$loop_count" < "1" ]]; then
            read -p "backup date: " backup_date
        else
            read -p "no such backup, try again: " backup_date
        fi
        let loop_count+=1
    done
    local -r backup_vm_file_path="$BACKUP_VM_BACKUP_PATH/$backup_date/$backup_restore_kuh_name/backup.tar.gz"

    # Copy backups to restore VM
    # The insecure way does not require typing anything in the copy popup window, but it channels the datastream over dom0 which is insecure. Designed for development.
    if [[ "$BACKUP_RESTORE_INSECURE_COPY" == "true" ]]; then

        log dom0 warn "you have set BACKUP_RESTORE_INSECURE_COPY=true in kuhbs/defaults.sh, using insecure but automatic method of copying the backup file"
        kuhbs_run_dom0 qvm-run --quiet --user root "$backup_restore_kuh_name" "mkdir -p /home/user/QubesIncoming/$BACKUP_VM/"

        # set -x does not display pipes very readable
        echo "+ qvm-run --pass-io --user root $BACKUP_VM \"cat $backup_vm_file_path\" | qvm-run --pass-io --user root $backup_restore_kuh_name \"cat - > /home/user/QubesIncoming/$BACKUP_VM/backup.tar.gz\""
        qvm-run --pass-io --user root "$BACKUP_VM" "cat $backup_vm_file_path" | qvm-run --pass-io --user root "$backup_restore_kuh_name" "cat - > /home/user/QubesIncoming/$BACKUP_VM/backup.tar.gz"

    # This way of copying the backup files will prompt for the destination VM in a graphical popup in dom0
    else
        log "$BACKUP_VM" info "select this destination VM: $backup_restore_kuh_name"
        kuhbs_run_dom0 qvm-run --quiet --user root "$BACKUP_VM" "qvm-copy $backup_vm_file_path"

    fi

    # Restore files
    log "$backup_restore_kuh_name" info "Restoring backup files"
    kuh_execute_command "$backup_restore_kuh_name" root "tar xvzf /home/user/QubesIncoming/$BACKUP_VM/backup.tar.gz -C /"

    # Overwrite and delete the files on the backed up kuh
    log "$backup_restore_kuh_name" info "overwriting restored backup file with random data and deleting"
    kuh_execute_command "$backup_restore_kuh_name" root "shred --iterations 3 --remove --force $qvm_verbose /home/user/QubesIncoming/$BACKUP_VM/backup.tar.gz"

}



# Check if a backup exists
verify_kuh_backup_exists() {

    # Parse arguments
    local -r backup_exists_kuh_name="$1"

    # Check if a backup is present
    if ! qvm-run --quiet --user root "$BACKUP_VM" "find $BACKUP_VM_BACKUP_PATH/*/$backup_exists_kuh_name/backup.tar.gz -type f" >/dev/null 2>&1; then
        return 1
    fi
}
