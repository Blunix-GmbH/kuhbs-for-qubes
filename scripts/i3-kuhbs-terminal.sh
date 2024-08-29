#!/bin/bash
#
# Spawn a xfce4-terminal in the VM that is currently the active window
# Make the background color of the terminal the same as the VM label

set -e



# Process arguments
if ! [[ -z "$1" ]]; then
    target_vm=$1
    if ! qvm-ls --quiet --fields name "$target_vm" 2>&1 >/dev/null; then
        echo "Error, no such VM: $target_vm, aborting!"
    fi
fi



get_id() {
    local id=$(xprop -root _NET_ACTIVE_WINDOW)
    echo ${id##* } # extract id
}

get_vm() {
    local id=$(get_id)
    local vm=$(xprop -id $id | grep '_QUBES_VMNAME(STRING)')
    local vm=${vm#*\"} # extract vmname
    echo ${vm%\"*} # extract vmname
}

get_color_text() {
    # labels used: black, orange, purple, blue, yellow, gray, green, red
    vm_label_color="$1"
    if [[ "black orange purple blue red" =~ "$vm_label_color" ]]; then
        echo "white"
    else
        echo "black"
    fi
}

get_color_bg() {
    vm="$1"
    #qvm-prefs "$vm" label
    echo black
}

main() {
    local vm=$(get_vm)
    # run terminal in VM
    if [[ -n "$vm" ]] && [[ -z "$target_vm" ]]; then
        color_bg=$(get_color_bg "$vm")
        color_text=$(get_color_text "$color_bg")
        qvm-run "$vm" "xfce4-terminal --hide-menubar --hide-borders --hide-toolbar --hide-scrollbar --color-bg $color_bg --color-text $color_text" &
    # run terminal in VM given as argument
    elif ! [[ -z "$target_vm" ]] && [[ "$target_vm" != "dom0" ]]; then
        color_bg=$(get_color_bg "$target_vm")
        color_text=$(get_color_text "$color_bg")
        qvm-run "$target_vm" "xfce4-terminal --hide-menubar --hide-borders --hide-toolbar --hide-scrollbar --color-bg $color_bg --color-text $color_text" &
    # run terminal in dom0
    else
        xfce4-terminal --hide-menubar --hide-borders --hide-toolbar --hide-scrollbar --color-bg black --color-text white
    fi
}

main
