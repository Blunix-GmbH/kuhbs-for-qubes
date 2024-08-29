kuhb_create() {

    log kuhbs info "creating kuhb $KUHB_NAME"

    # Configure i3wm to automatically assign windows to specific workspaces
    if ! [[ -z "$I3_ASSIGN" ]]; then
        if grep --quiet --fixed-strings "$I3_ASSIGN" "$I3_CONFIG_PATH" ; then
            log kuhbs verbose "$I3_CONFIG_PATH already contains: $I3_ASSIGN"
        else
            log kuhbs verbose "Appending to $I3_CONFIG_PATH: $I3_ASSIGN"
            echo "$I3_ASSIGN" >> "$I3_CONFIG_PATH"
        fi
    fi

    # Create in order: StandaloneVM, TemplateVM, AppVM, Named DisposableVM, Unnamed DisposableVM (which is only a launcher)
    for kuh_type in sta tpl app ndp udp; do

        local kuh_name="${kuh_type}-${KUHB_NAME}"
        local kuh_path="$KUHB_PATH/$kuh_type"

        # Only create kuh if its relevant to the KUHB_TYPE
        [[ "$kuh_type" == "sta" ]] && [[ "$KUHB_TYPE" != "sta" ]] && continue
        [[ "$kuh_type" == "sta" ]] && [[ "$KUHB_TYPE" =~ (tpl|app|ndp|udp) ]] && continue
        [[ "$kuh_type" == "tpl" ]] && [[ "$KUHB_TYPE" == "sta" ]] && continue
        [[ "$kuh_type" == "app" ]] && [[ "$KUHB_TYPE" =~ (sta|tpl) ]] && continue
        [[ "$kuh_type" == "ndp" ]] && [[ "$KUHB_TYPE" =~ (sta|tpl|app|udp) ]] && continue
        [[ "$kuh_type" == "udp" ]] && [[ "$KUHB_TYPE" =~ (tpl|app|ndp|udp) ]] && continue


        # Verify the kuh does not already exist
        if [[ "$kuh_type" != "udp" ]]; then
            if verify_kuh_exists "$kuh_name"; then
                log "$kuh_name" error "kuh already exists, remove and create the kuhb"
            else
                log kuhbs info "creating kuh of type $kuh_type"
            fi
        fi


        # Create StandaloneVM kuh
        # As StandaloneVMs can't use the Qubes update proxy by default, the setup steps are performend in a temporary TemplateVM and then create a StandaloneVM from it
        if [[ "$kuh_type" == "sta" ]]; then

            # Clone the TemplateVM and install networking packages so we can use apt and other tools to install software
            [[ -z "$TEMPLATE" ]] && log "$kuh_name" error "TEMPLATE variable is not defined in config.sh"
            kuhbs_run_dom0 qvm-clone $qvm_verbose "$TEMPLATE" "${kuh_name}-tmp"

            kuh_script "${kuh_name}-tmp" root $KUHBS_COMMON_SCRIPTS_PATH/apt-sources-list-enforce-http.sh
            kuh_script "${kuh_name}-tmp" root $KUHBS_COMMON_SCRIPTS_PATH/apt-update.sh
            kuh_script "${kuh_name}-tmp" root $KUHBS_COMMON_SCRIPTS_PATH/networking-packages.sh

            # Create the StandaloneVM from the temporary TemplateVM
            log "$kuh_name" info "creating StandaloneVM by cloning TemplateVM ${kuh_name}-tmp"
            kuhbs_run_dom0 qvm-clone --class StandaloneVM "$TEMPLATE" $qvm_verbose "$kuh_name"

            # Remove the temporary TemplateVM
            kuh_remove "${kuh_name}-tmp"

            # Disable Qubes LVM snapshots, which are created during shutdown, we have our own backup strategy
            log "$kuh_name" info "disabling automatic LVM snapshots on shutdown"
            kuhbs_run_dom0 qvm-volume config "$kuh_name":root revisions_to_keep 0
            kuhbs_run_dom0 qvm-volume config "$kuh_name":private revisions_to_keep 0

            # Add the tag StandaloneVM to use it in a policy to access the UpdatesProxy
            log "$kuh_name" info "adding the StandaloneVM tag to use it for the qubes policy UpdatesProxy"
            kuhbs_run_dom0 qvm-tags "$kuh_name" add StandaloneVM

            # Allow VMs with the tag StandaloneVM to use an updates proxy
            if ! [[ -f /etc/qubes/policy.d/99-kuhbs.policy ]] || ! grep -q 'StandaloneVM' /etc/qubes/policy.d/99-kuhbs.policy; then
                log "$kuh_name" info "creating /etc/qubes/policy.d/99-kuhbs.policy for allowing UpdatesProxy with VMs tagged StandaloneVM"
                echo '+ echo "qubes.UpdatesProxy      *   @type:StandaloneVM      @default    allow target=ndp-kuhbs-net-gateway" > /etc/qubes/policy.d/99-kuhbs.policy'
                echo "qubes.UpdatesProxy      *   @type:StandaloneVM      @default    allow target=ndp-kuhbs-net-gateway" > /etc/qubes/policy.d/99-kuhbs.policy
            fi


        # Create TemplateVM kuh
        elif [[ "$kuh_type" == "tpl" ]]; then
            [[ -z "$TEMPLATE" ]] && log "$kuh_name" error "TEMPLATE variable is not defined in config.sh"
            log "$kuh_name" info "creating TemplateVM by cloning TemplateVM $TEMPLATE"
            kuhbs_run_dom0 qvm-clone $qvm_verbose "$TEMPLATE" "$kuh_name"
            # Disable Qubes LVM snapshots, which are created during shutdown, we have our own backup strategy
            log "$kuh_name" info "disabling automatic LVM snapshots on shutdown"
            kuhbs_run_dom0 qvm-volume config "$kuh_name":root revisions_to_keep 0
            kuhbs_run_dom0 qvm-volume config "$kuh_name":private revisions_to_keep 0


        # Create AppVM kuh
        elif [[ "$kuh_type" == "app" ]]; then
            log "$kuh_name" info "creating AppVM with TemplateVM tpl-$KUHB_NAME"
            kuhbs_run_dom0 qvm-create --class AppVM --label "${use_app_prefs['label']}" --template "tpl-$KUHB_NAME" "$kuh_name"
            # Disable Qubes LVM snapshots, which are created during shutdown, we have our own backup strategy
            log "$kuh_name" info "disabling automatic LVM snapshots on shutdown"
            kuhbs_run_dom0 qvm-volume config "$kuh_name":private revisions_to_keep 0


        # Create named DisposableVM kuh
        elif [[ "$kuh_type" == "ndp" ]]; then
            log "$kuh_name" info "setting the pref template_for_dispvms in the AppVM app-${KUHB_NAME}"
            kuhbs_run_dom0 qvm-prefs "app-${KUHB_NAME}" template_for_dispvms true
            log "$kuh_name" info "creating named DisposableVM with AppVM app-${KUHB_NAME}"
            kuhbs_run_dom0 qvm-create --class DispVM --label "${use_ndp_prefs['label']}" --template "app-${KUHB_NAME}" "$kuh_name"

        fi


        # Does not apply for unnamed DisposableVMs
        if [[ "$kuh_type" =~ (sta|tpl|app|ndp) ]]; then

            # Set qvm-prefs
            log "$kuh_name" info "setting qvm-prefs, qvm-features and qvm-service"
            [[ "$kuh_type" == "sta" ]] && for pref_key in ${!use_sta_prefs[@]}; do kuhbs_run_dom0 qvm-prefs "$kuh_name" $pref_key ${use_sta_prefs[$pref_key]}; done
            [[ "$kuh_type" == "tpl" ]] && for pref_key in ${!use_tpl_prefs[@]}; do kuhbs_run_dom0 qvm-prefs "$kuh_name" $pref_key ${use_tpl_prefs[$pref_key]}; done
            [[ "$kuh_type" == "app" ]] && for pref_key in ${!use_app_prefs[@]}; do kuhbs_run_dom0 qvm-prefs "$kuh_name" $pref_key ${use_app_prefs[$pref_key]}; done
            [[ "$kuh_type" == "ndp" ]] && for pref_key in ${!use_ndp_prefs[@]}; do kuhbs_run_dom0 qvm-prefs "$kuh_name" $pref_key ${use_ndp_prefs[$pref_key]}; done

            # Set qvm-services
            [[ "$kuh_type" == "sta" ]] && for service_key in ${!use_sta_services[@]}; do kuhbs_run_dom0 qvm-service "$kuh_name" $service_key ${use_sta_services[$service_key]}; done
            [[ "$kuh_type" == "tpl" ]] && for service_key in ${!use_tpl_services[@]}; do kuhbs_run_dom0 qvm-service "$kuh_name" $service_key ${use_tpl_services[$service_key]}; done
            [[ "$kuh_type" == "app" ]] && for service_key in ${!use_app_services[@]}; do kuhbs_run_dom0 qvm-service "$kuh_name" $service_key ${use_app_services[$service_key]}; done
            [[ "$kuh_type" == "ndp" ]] && for service_key in ${!use_NDP_SERVICES[@]}; do kuhbs_run_dom0 qvm-service "$kuh_name" $service_key ${use_NDP_SERVICES[$service_key]}; done

            # Set qvm-features
            [[ "$kuh_type" == "sta" ]] && for feature_key in ${!use_sta_features[@]}; do kuhbs_run_dom0 qvm-features "$kuh_name" $feature_key ${use_sta_features[$feature_key]}; done
            [[ "$kuh_type" == "tpl" ]] && for feature_key in ${!use_tpl_features[@]}; do kuhbs_run_dom0 qvm-features "$kuh_name" $feature_key ${use_tpl_features[$feature_key]}; done
            [[ "$kuh_type" == "app" ]] && for feature_key in ${!use_app_features[@]}; do kuhbs_run_dom0 qvm-features "$kuh_name" $feature_key ${use_app_features[$feature_key]}; done
            [[ "$kuh_type" == "ndp" ]] && for feature_key in ${!use_ndp_features[@]}; do kuhbs_run_dom0 qvm-features "$kuh_name" $feature_key ${use_ndp_features[$feature_key]}; done

        fi


        # Execute pre hook script
        if [[ -x $kuh_path/hooks/create-pre.sh ]]; then
            log dom0 info "executing pre creation hook script for kuhb $KUHB_NAME"
            kuhbs_run_dom0 $kuh_path/hooks/create-pre.sh
        else
            log "$kuh_name" verbose "pre hook script $kuh_path/hooks/create-pre.sh not found or not executable"
        fi


        # Restore backups if present
        if ! verify_kuh_backup_exists "$kuh_name"; then
            log "$kuh_name" info "no backups found"
        else
            kuh_backup_restore "$kuh_name"
        fi


        # Run setup scripts
        if [[ "$kuh_type" =~ (sta|tpl|app) ]]; then
            [[ -d "$kuh_path/scripts"/ ]] && kuh_run_scripts_dir "$kuh_name" "$kuh_path/scripts"
        else
            log "$kuh_name" verbose "scripts dir $kuh_path/scripts/ not found"
        fi


        # Shutdown the kuh
        if [[ "$kuh_type" =~ (sta|tpl|app|ndp) ]]; then
            log "$kuh_name" info "shutting down"
            kuhbs_run_dom0 qvm-shutdown $qvm_verbose --wait --force "$kuh_name"
        fi


        # Update Qubes internal launcher appmenus (.desktop files)
        kuhbs_run_dom0 qvm-appmenus --update --force "$kuh_name"


        # Run post hooks
        if [[ -x "$kuh_path/hooks/create-post.sh" ]]; then
            log dom0 info "executing post creation hook script for kuhb $KUHB_NAME"
            kuhbs_run_dom0 "$kuh_path/hooks/create-post.sh"
        else
            log "$kuh_name" verbose "post hook script $kuh_path/hooks/create-post.sh not found or not executable"
        fi


    done

    # Create launchers
    for launcher_line in "${LAUNCHERS[@]}"; do
        # Intentionally unquoted to give kuhb_launcher_create() multiple arguments
        kuhb_launcher_create $launcher_line
    done

}
