# Wrapper for creating a dmenu launcher
kuhb_launcher_create() {

    # Parse arguments
    local -r launcher_user="$1"
    local -r launcher_name="$2"
    local -r launcher_dispvm="$3"
    local -r launcher_command="${@:4}"
    local -r launcher_path="${KUHBS_CONFIG_PATH_LAUNCHERS}"
    local -r launcher_file="${launcher_path}/${KUHB_NAME}-${launcher_name}"

    # Override KUHB_TYPE in case we are creating launchers for unnamed DisposableVMs - then its app
    if [[ "$KUHB_TYPE" == "udp" ]]; then
        local -r launcher_KUHB_TYPE=app
    else
        local -r launcher_KUHB_TYPE="$KUHB_TYPE"
    fi

    # Save the launcher command as a variable
    launcher_content=$(cat << EOM
TARGET=${launcher_KUHB_TYPE}-${KUHB_NAME} \
TERMINAL_USER=$launcher_user \
DISPVM=$launcher_dispvm \
COMMAND="$launcher_command" \
TITLE="${KUHB_TYPE}-${KUHB_NAME}_${launcher_command}" \
$KUHBS_BASE_PATH_SCRIPTS/i3-qvm-launch.sh
EOM
    )

    # Check if the launcher exists and its content is equal to launcher_content
    if [[ -f "$launcher_file" ]] && [[ $(cat "$launcher_file") == "$launcher_content" ]]; then
        log dom0 info "launcher exists $launcher_file"
        return 0

    # Check if the launcher exists and its content is not equal to launcher_content
    elif [[ -f "$launcher_file" ]] && [[ $(cat "$launcher_file") != "$launcher_content" ]]; then
        log dom0 info "updating launcher $launcher_file"

    # launcher does not exist, create it
    else
        log dom0 info "creating launcher $launcher_file"

    fi


    # If verbose mode is enabled, show how the launcher is created
    if ! [[ "$verbose" == "false" ]]; then
        # kuhbs_run_dom0 does not work with pipes, showing the commands using set -x
        set -x
        mkdir -p "$launcher_path"
        echo -e "$launcher_content" | tee "$launcher_file"
        chmod --verbose 700 "$launcher_file"
        { set +x; } 2>/dev/null
        # If debug mode is enabled, set +x would disable debug mode, hence enabling it again
        [[ "$debug" == "true" ]] && set -x

    # If verbose mode is not enabled create the launcher without output
    else
        mkdir -p "$launcher_path"
        echo -e "$launcher_content" > "$launcher_file"
        chmod 700 "$launcher_file"

    fi

}


# Remove a launcher
kuhb_launcher_remove() {

    # Parse arguments
    local -r launcher_user="$1"
    local -r launcher_name="$2"
    local -r launcher_dispvm="$3"
    local -r launcher_command="${@:4}"
    local -r launcher_file="${KUHBS_CONFIG_PATH_LAUNCHERS}/${KUHB_NAME}-${launcher_name}"

    # Check if the launcher exists and remove it
    if [[ -f "$launcher_file" ]]; then
        log dom0 info "removing launcher $launcher_file"
        kuhbs_run_dom0 rm "$launcher_file"

    # Inform the curious user that the launcher was absent
    else
        log dom0 verbose "launcher absent $launcher_file"

    fi

}
