declare -r KUHB_TYPE=ndp
declare -r TEMPLATE=debian-12-minimal

# Has PCI device attached and needs to be virt_mode: hvm
declare -rA NDP_PREFS=(
    ["virt_mode"]=hvm
    ["label"]=blue
    ["provides_network"]=true
)

declare -rA NDP_SERVICES=(
    ["qubes-network"]=true
    ["network-manager"]=true
)

declare -r LAUNCHERS=(
    "root terminal 0 terminal"
    "root network-manager 0 /usr/bin/nm-connection-editor"
    "root wireshark 0 /usr/bin/wireshark"
)
