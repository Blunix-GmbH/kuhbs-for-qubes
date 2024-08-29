# Check if a VM exists
verify_kuh_exists() {

    # Parse arguments
    local -r verify_qube_vm="$1"

    # Check if the kuh is a Qubes OS VM (qube)
    qvm-check --quiet "$verify_qube_vm" 2>/dev/null || return 1
}



# Check if all VMs of a kuhb have been created
verify_kuhb_exists() {

    # Process arguments
    local verify_kuhb_name="$1"
    local verify_kuhb_type="$2"

    # Check VM types
    if [[ "$verify_kuhb_type" == "sta" ]]; then
        verify_kuh_exists "sta-${verify_kuhb_name}" && return 0 || return 1
    elif [[ "$verify_kuhb_type" == "tpl" ]]; then
        verify_kuh_exists "tpl-${verify_kuhb_name}" && return 0 || return 1
    elif [[ "$verify_kuhb_type" =~ (app|udp) ]]; then
        verify_kuh_exists "tpl-${verify_kuhb_name}" && verify_kuh_exists "app-${verify_kuhb_name}" && return 0 || return 1
    elif [[ "$verify_kuhb_type" == "ndp" ]]; then
        verify_kuh_exists "tpl-${verify_kuhb_name}" && verify_kuh_exists "app-${verify_kuhb_name}" && verify_kuh_exists "ndp-${verify_kuhb_name}" && return 0 || return 1
    fi

}
