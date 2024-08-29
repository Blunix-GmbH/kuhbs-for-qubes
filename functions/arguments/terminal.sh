# Open a terminal in a specific VM
kuh_terminal() {

    local -r terminal_kuh_name="$1"
    local -r terminal_kuh_user="${2:-user}"

    # Determine the terminal and text color
    local -r vm_label_color=$(qvm-prefs "$terminal_kuh_name" label)
    if [[ "black orange purple blue red" =~ "$vm_label_color" ]]; then
        local -r color_test="white"
    else
        local -r color_test="black"
    fi

    # Start a terminal
    if qvm-run --quiet "$terminal_kuh_name" "which xfce4-terminal" >/dev/null 2>&1; then
        kuhbs_run_dom0 qvm-run --quiet --user "$terminal_kuh_user" "$terminal_kuh_name" "xfce4-terminal --hide-menubar --hide-borders --hide-toolbar --hide-scrollbar" &

    elif qvm-run --quiet "$terminal_kuh_name" "which xterm" >/dev/null 2>&1; then
        kuhbs_run_dom0 qvm-run --quiet --user "$terminal_kuh_user" "$terminal_kuh_name" "$XTERM_COMMAND" &

    else
        log "$terminal_kuh_name" error "neither xfce4-terminal nor xterm is installed"

    fi

}
