declare -r KUHB_TYPE=ndp
declare -r TEMPLATE=debian-12-xfce

# To download multibootusb
declare -rA TPL_PREFS=(
    ["netvm"]="ndp-kuhbs-net-gateway"
)

declare -rA NDP_PREFS=(
    ["autostart"]=true
    ["label"]=blue
)

declare -r LAUNCHERS=(
    "root terminal 0 terminal"
)
