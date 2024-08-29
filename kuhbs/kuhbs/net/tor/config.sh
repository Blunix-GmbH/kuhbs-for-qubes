declare -r KUHB_TYPE=ndp
declare -r TEMPLATE=whonix-gateway-17

declare -rA NDP_PREFS=(
    ["virt_mode"]=hvm
    ["label"]=blue
    ["netvm"]=ndp-kuhbs-net-gateway
    ["provides_network"]=true
)

declare -rA NDP_SERVICES=(
    ["qubes-network"]=true
)

declare -r LAUNCHERS=(
    "root terminal 0 terminal"
    "user tor-control-panel 0 /usr/bin/tor-control-panel"
)
