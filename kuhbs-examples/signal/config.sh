declare -r KUHB_TYPE=app
declare -r TEMPLATE=debian-12-minimal

# To download the apt gpg signing key
declare -rA TPL_PREFS=(
    ["netvm"]=ndp-kuhbs-net-gateway
)

declare -rA APP_PREFS=(
    ["label"]=green
    ["netvm"]=ndp-kuhbs-net-gateway
)

declare -r APP_BACKUP_PATHS=(
    "/home/user/.config/Signal"
)

declare -r LAUNCHERS=(
    "user terminal 0 terminal"
    "user signal 0 /usr/bin/kuhbs-signal"
)

declare -r I3_ASSIGN='assign [class="signal"] 22'
