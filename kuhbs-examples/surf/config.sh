declare -r KUHB_TYPE=udp
declare -r TEMPLATE=debian-12-minimal

# For installing the flatpak repo
declare -rA TPL_PREFS=(
    ["netvm"]=ndp-kuhbs-net-gateway
)

declare -rA APP_PREFS=(
    ["netvm"]=ndp-kuhbs-net-gateway
    ["label"]=orange
    ["template_for_dispvms"]=true
)

declare -r LAUNCHERS=(
    "user firefox 1 /usr/bin/kuhbs-firefox"
    "user librewolf 1 /usr/bin/kuhbs-librewolf"
    "user chromium 1 /usr/bin/kuhbs-chromium"
    "user terminal 1 /usr/bin/terminal"
)

declare -r I3_ASSIGN='assign [class="surf"] 2'
