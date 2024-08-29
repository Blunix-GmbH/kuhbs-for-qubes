# Log strings
# Usage: log <kuh_name> <log_level> "<log_message>"
# exit 1 is run if the log level error is used
log() {

    # Parse arguments
    local -r log_kuh_name="$1"
    local -r log_level="$2"
    local -r log_message="$3"

    # Get the label (color) of the qubes VM
    local -r log_qube_color=$(qvm-ls "$log_kuh_name" --fields label --raw-data 2>/dev/null || true)

    # Colorize the VM name
    if [[ "$log_kuh_name" == "kuhbs" ]]; then
        local -r log_kuhb_color="${COL_BOLD}$(tput setaf 7)k${COL_PURPLE}u$(tput setaf 7)h${COL_PURPLE}b$(tput setaf 7)s${COL_RESET}"
    elif [[ "$log_qube_color" == "red" ]]; then
        local -r log_kuhb_color="${COL_RED}$log_kuh_name${COL_RESET}"
    elif [[ "$log_qube_color" == "orange" ]]; then
        local -r log_kuhb_color="${COL_ORANGE}$log_kuh_name${COL_RESET}"
    elif [[ "$log_qube_color" == "yellow" ]]; then
        local -r log_kuhb_color="${COL_YELLOW}$log_kuh_name${COL_RESET}"
    elif [[ "$log_qube_color" == "green" ]]; then
        local -r log_kuhb_color="${COL_GREEN}$log_kuh_name${COL_RESET}"
    elif [[ "$log_qube_color" == "gray" ]]; then
        local -r log_kuhb_color="${COL_GRAY}$log_kuh_name${COL_RESET}"
    elif [[ "$log_qube_color" == "blue" ]]; then
        local -r log_kuhb_color="${COL_BLUE}$log_kuh_name${COL_RESET}"
    elif [[ "$log_qube_color" == "purple" ]]; then
        local -r log_kuhb_color="${COL_PURPLE}$log_kuh_name${COL_RESET}"
    elif [[ "$log_qube_color" == "black" ]]; then
        local -r log_kuhb_color="${COL_BLACK}$log_kuh_name${COL_RESET}"
    else
        local -r log_kuhb_color="${COL_GRAY}$log_kuh_name${COL_RESET}"
    fi

    # Calculate spacing
    local -r kuh_name_spaces=$(($KUHBS_LOG_SPACING - $(echo $log_kuh_name | wc -c)))

    # Print log message
    if [[ "$log_level" == "verbose" ]]; then
        # Only log if verbose is defined
        if ! [[ "$verbose" == "false" ]]; then
            # Log to stdout
            >&1 echo -e "${COL_BOLD}${COL_BLUE}DEBUG${COL_RESET} $log_kuhb_color$(printf %$kuh_name_spaces's')${COL_RESET} ${COL_BLUE}  $log_message${COL_RESET}"
        fi

    elif [[ "$log_level" == "info" ]]; then
        # Log to stdout
        >&1 echo -e "${COL_BOLD}${COL_GREEN}INFO${COL_RESET} $log_kuhb_color$(printf %$kuh_name_spaces's')${COL_RESET} ${COL_GREEN}   $log_message${COL_RESET}"

    elif [[ "$log_level" == "warn" ]]; then
        # Log to stderr
        >&2 echo -e "${COL_BOLD}${COL_ORANGE}WARN${COL_RESET} $log_kuhb_color$(printf %$kuh_name_spaces's')${COL_RESET} ${COL_ORANGE}   $log_message${COL_RESET}"

    elif [[ "$log_level" == "error" ]]; then
        # Log to stderr
        >&2 echo -e "${COL_BOLD}${COL_RED}ERROR${COL_RESET} $log_kuhb_color$(printf %$kuh_name_spaces's')${COL_RESET} ${COL_RED}  $log_message${COL_RESET}"
        exit 1

    else
        # Log to stderr
        >&2 echo "${COL_BOLD}${COL_RED}ERROR no such log level: $log_level${COL_RESET}"
        exit 1
    fi
}
