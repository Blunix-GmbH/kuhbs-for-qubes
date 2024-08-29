# Remove all qubes VMs associated with a kuhb
kuhb_remove() {

    log kuhbs info "deleting type $KUHB_TYPE kuhb ${KUHB_NAME}"

    # Remove automatic window configuration from i3
    if ! [[ -z "$I3_ASSIGN" ]]; then
        if grep --quiet --fixed-strings "$I3_ASSIGN" "$I3_CONFIG_PATH" ; then
            log kuhbs info "removing from $I3_CONFIG_PATH: $I3_ASSIGN"
            kuhbs_run_dom0 sed -i "/^$I3_ASSIGN$/d" $I3_CONFIG_PATH
        else
            log kuhbs verbose "$I3_CONFIG_PATH does not contain: $I3_ASSIGN"
        fi
    fi

    # iterate possible qubes VM types and remove VM if present
    for kuh_type in ndp app tpl sta; do

        # Skip types that can not be part of this kuhb
        [[ "$kuh_type" == sta ]] && [[ "$KUHB_TYPE" != sta ]] && continue
        [[ "$kuh_type" == app ]] && [[ "$KUHB_TYPE" =~ (sta|tpl) ]] && continue
        [[ "$kuh_type" == tpl ]] && [[ "$KUHB_TYPE" =~ sta ]] && continue
        [[ "$kuh_type" == ndp ]] && [[ "$KUHB_TYPE" =~ (sta|tpl|app) ]] && continue

        # Set the name of the kuh to remove
        local kuh_name="${kuh_type}-${KUHB_NAME}"

        # Skip absent kuh
        if ! verify_kuh_exists "$kuh_name"; then
            log "$kuh_name" info "kuh absent"
            continue
        fi

        # Execute remove hook
        if [[ -x "$KUHB_PATH/$kuh_type/hooks/remove.sh" ]]; then
            log "$kuh_name" info "executing remove hook $KUHB_PATH/$kuh_type/hooks/remove.sh"
            kuhbs_run_dom0 "$KUHB_PATH/$kuh_type/hooks/remove.sh"
        else
            log "$kuh_name" verbose "remove hook $KUHB_PATH/$kuh_type/hooks/remove.sh not found or not executable"
        fi
        # Remove the kuh
        kuh_remove "$kuh_name"

    done

    # Remove launchers
    for launcher_line in "${LAUNCHERS[@]}"; do
        # Intentionally unquoted to give kuhb_launcher_create() multiple arguments
        kuhb_launcher_remove $launcher_line
    done

}
