declare -r KUHB_TYPE=ndp
declare -r TEMPLATE=debian-12-minimal

declare -r TPL_BACKUP_PATHS=(
    "/etc/wpa_supplicant"
)

# To download the keyring with wget
declare -rA TPL_PREFS=(
    ["netvm"]=ndp-kuhbs-net-gateway
)

# Has PCI device attached and needs to be virt_mode: hvm
declare -rA NDP_PREFS=(
    ["virt_mode"]=hvm
    ["label"]=blue
    ["netvm"]=ndp-kuhbs-net-gateway
    ["autostart"]=true
)

declare -r LAUNCHERS=(
    "root terminal 0 terminal"
    "root wireshark 0 /usr/bin/wireshark"
)
