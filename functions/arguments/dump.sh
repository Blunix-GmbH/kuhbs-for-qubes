# kuhbs dump name/of/kuhb
kuh_dump() {

    local -r my_kuh_name=$1

    # Verify we can process the VM
    if [[ "$my_kuh_name" == "dom0" ]]; then
        log dom0 error "kuhbs dump can not be used for dom0"
    elif ! qvm-ls --raw-data --running "$my_kuh_name" | grep -q "$my_kuh_name"; then
        log "$my_kuh_name" error "the kuh is not running"
    fi

    # Pause the VM, dump the memory and create dd images of its LVM volumes
    local -r my_dump_dir="$DUMP_DIR/${my_kuh_name}"
    mkdir -p "$my_dump_dir"
    log "$my_kuh_name" info "pausing"
    kuhbs_run_dom0 sudo xl pause "$my_kuh_name"
    log "$my_kuh_name" info "dumping memory to .img"
    kuhbs_run_dom0 sudo xl dump-core "$my_kuh_name" "$my_dump_dir/core.img"
    log "$my_kuh_name" info "creating dd images of private, root and volatile volume"
    double_dashed_name=$(echo "$my_kuh_name" | sed 's/-/--/g')
    kuhbs_run_dom0 sudo dd if="/dev/mapper/qubes_dom0-vm--${double_dashed_name}--private" of="$my_dump_dir/private.img"
    kuhbs_run_dom0 sudo dd if="/dev/mapper/qubes_dom0-vm--${double_dashed_name}--root" of="$my_dump_dir/root.img"
    kuhbs_run_dom0 sudo dd if="/dev/mapper/qubes_dom0-vm--${double_dashed_name}--volatile" of="$my_dump_dir/volatile.img"
    echo
    log kuhbs info "to unpause the VM run: xl unpause $my_kuh_name"

}
