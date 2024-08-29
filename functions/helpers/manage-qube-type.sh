# delete kuh if it exists
kuh_remove() {

    # Parse arguments
    local -r remove_kuh_name="$1"

    # Shutdown and remove kuh
    if verify_kuh_exists "$remove_kuh_name" >/dev/null 2>&1; then
        log "$remove_kuh_name" info "removing kuh $remove_kuh_name"
        kuhbs_run_dom0 qvm-shutdown $qvm_verbose --wait --force "$remove_kuh_name"
        kuhbs_run_dom0 qvm-remove $qvm_verbose --force "$remove_kuh_name"
    fi
}



# Copy file or directory to VM, commonly templates that are used in scripts
kuh_copy() {

    # Parse arguments
    local -r copy_kuh_name="$1"
    local -r copy_file_path="$2"
    local -r copy_file_basename=$(basename "$copy_file_path")

    # Remove QubesIncoming directory
    if [[ "$verbose" == "false" ]]; then
        qvm-run --quiet --user root "$copy_kuh_name" "rm -rf /home/user/QubesIncoming/dom0/$copy_file_basename"

    # Remove QubesIncoming directory verbose
    else
        log "$copy_kuh_name" verbose "deleting /home/user/QubesIncoming/dom0/$copy_file_basename"
        kuhbs_run_dom0 qvm-run --quiet --user root "$copy_kuh_name" "rm -rf /home/user/QubesIncoming/dom0/$copy_file_basename"

    fi

    # Copy file
    log "$copy_kuh_name" info "copying $copy_file_path"
    kuhbs_run_dom0 qvm-copy-to-vm "$copy_kuh_name" "$copy_file_path"
}
