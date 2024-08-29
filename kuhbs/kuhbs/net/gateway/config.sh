declare -r KUHB_TYPE=ndp
declare -r TEMPLATE=debian-12-minimal

declare -r TPL_BACKUP_PATHS=(
    "/etc/wpa_supplicant"
)

# Needs network during setup to download blocklists for dnscrypt-proxy
declare -rA TPL_PREFS=(
    ["netvm"]=sys-net
)

# Has PCI device attached and needs to be virt_mode: hvm
declare -rA NDP_PREFS=(
    ["virt_mode"]=hvm
    ["label"]=blue
    ["netvm"]=sys-net
    ["provides_network"]=true
    ["autostart"]=true
)

declare -rA NDP_SERVICES=(
    ["qubes-network"]=true
)

declare -r LAUNCHERS=(
    "root terminal 0 terminal"
    "root wireshark 0 /usr/bin/wireshark"
)
