# kuhbs variable defaults
#
# Read and modify this file according to your needs



## CONFIG FILE AND DIRECTORY LOCATIONS
# Where KUHBS config files are stored
declare -r KUHBS_CONFIG_PATH=/home/user/.kuhbs
# Where the kuhbs git directory is located
declare -r KUHBS_BASE_PATH=/home/user/kuhbs
# Where to store ram dump and LVM volume dd images from KUHBS dump
declare -r DUMP_DIR=$KUHBS_BASE_PATH/dumps
# Paths used by the kuhbs executable
declare -r KUHBS_BASE_PATH_SCRIPTS=$KUHBS_BASE_PATH/scripts
declare -r KUHBS_CONFIG_PATH_KUHBS=$KUHBS_BASE_PATH/kuhbs
declare -r KUHBS_COMMON_SCRIPTS_PATH=$KUHBS_BASE_PATH/setup-scripts



## NETWORK VM SETTINGS
# Default update proxy VM
declare -r KUHBS_UPDATES_PROXY=ndp-kuhbs-net-gateway



## BACKUP SETTINGS
# VM where the backup usb disk is mounted for KUHBS backup
declare -r BACKUP_VM=sys-usb #ndp-kuhbs-usb
# USB device
declare -r BACKUP_VM_DEVICE=/dev/sda3
# Where to mount the device
declare -r BACKUP_VM_MOUNTPOINT=/mnt
# Subdirectory of BACKUP_VM_MOUNTPOINT where backups are stored
declare -r BACKUP_VM_BACKUP_PATH=$BACKUP_VM_MOUNTPOINT/kuhbs-backups
#
# !!! WARNING !!! SETTING INSECURE_COPY TO "true" IS A POTENTIAL SECURITY RISK !!!
# When copying files between the backup storage (kuhbs-usb) and the backup client VMs, the following BASH oneliner can be used to copy a file without a graphical prompt:
# dom0: qvm-run --pass-io -u root <source_vm> "cat file.txt" | qvm-run --pass-io -u root <target_vm> "cat - > /destination/path/file.txt"
# However as the data stream is piped over dom0, this is a security risk. If you are willing to type "kuhbs-usb" each time you copy a backup file, leave this at "false". If you are willing to take the risk, set it to "true".
declare -r BACKUP_CREATE_INSECURE_COPY=true
# The same as above but for restoring backups
declare -r BACKUP_RESTORE_INSECURE_COPY=true




## TERINAL SETTINGS
# Maximum spacing for cli output between first and second column. Example:
# kuhbs           <->           INFO   kuhb "checks-sys-net-nic" of type "ndp"
# tpl-checks-sys-net-nic   <->  INFO   kuh absent
declare -r KUHBS_LOG_SPACING=25
# xterm command used to open new terminals in VMs
declare -r XTERM_PATH="/usr/bin/xterm"
declare -r XTERM_ARGS="-fs 12 -fa DejaVuSansMono -bg black -fg white +sb -si"
declare -r XTERM_COMMAND="$XTERM_PATH $XTERM_ARGS"
# BASH colors, used in the log() function in `kuhbs/functions/helpers/log.sh`
declare -r COL_RED=$(tput setaf 196)
declare -r COL_ORANGE=$(tput setaf 202)
declare -r COL_YELLOW=$(tput setaf 226)
declare -r COL_GREEN=$(tput setaf 46)
declare -r COL_GRAY=$(tput setaf 249)
declare -r COL_BLUE=$(tput setaf 39)
declare -r COL_PURPLE=$(tput setaf 129)
# Black background white text
declare -r COL_BLACK=$(tput setb 0)$(tput setaf 15)
# White background black text
#declare -r COL_BLACK=$(tput setb 15)$(tput setaf 0)
declare -r COL_BOLD=$(tput bold)
# Reset to default color scheme
declare -r COL_RESET=$(tput sgr0)



## I3WM
# Config path for i3wm
declare -r I3_CONFIG_PATH=/home/user/.config/i3/config
# Location of dmenu launchers
declare -r KUHBS_CONFIG_PATH_LAUNCHERS=$KUHBS_CONFIG_PATH/launchers
# split i3 screen vertical or horizontal when opening windows
# Given as argument like: i3-msg --quiet split $I3_SPLIT_METHOD
declare -r I3_SPLIT_METHOD=vertical
# Default workspace to assign, default is none (can be overridden in the kuhb's config.sh)
declare I3_ASSIGN=""



## TEST OR DEBUG MODE
# Enabling this skips all scripts defined in `kuhbs/kuhbs/<my-kuhbs>/{sta,tpl,app,ndp}/scripts/` and instead executes `/bin/true`. This can speed up debugging of kuhbs.
# "true" to enable, "false" to disable
declare -r KUHBS_CHECK_MODE=false



## DEFAULT TEMPLATEVM TEMPLATE
# The default TemplateVM if none is specified in the kuhb's config.sh
declare -r DEFAULT_TPL_TEMPLATE=tpl-deb-12



## DEFAULT QVM-PREFS
# You can override all qvm-prefs, qvm-service and qvm-features settings in `kuhbs/kuhbs/<my-kuhb>/config.sh`
# Default StandaloneVM prefs
declare -rA DEFAULT_STA_PREFS=(
    # More secure and hence default
    ['virt_mode']=hvm
    # netvm is always disabled by default
    ['netvm']=None
    # by default all VMs are gray, the user has to set a color using prefs in the config.sh file
    ['label']=purple
    # Disable Qubes OS backups - we have our own backup system
    ['include_in_backups']=False
)
# Default TemplateVM prefs
declare -rA DEFAULT_TPL_PREFS=(
    # Templates do not need a network VM by default and can install packages using the apt proxy of Qubes OS
    ['netvm']=None
    # Purple is the default color of all VMs kuhbs creates
    ['label']=purple
    ['virt_mode']=hvm
    # Ressource settings
    # TemplatesVMs do only run for their setup and upgrade, hence we can assign many ressources to make that fast.
    ['vcpus']=4
    ['memory']=4096
    ['maxmem']=8192
    ['include_in_backups']=False
)
# Default AppVM defaults
declare -rA DEFAULT_APP_PREFS=(
    ['netvm']=None
    ['label']=purple
    ['template_for_dispvms']=false
    ['autostart']=false
    ['include_in_backups']=false
    ['virt_mode']=hvm
)
# Default Named DisposableVM defaults
declare -rA DEFAULT_NDP_PREFS=(
    ['netvm']=None
    ['label']=purple
    ['include_in_backups']=False
    ['virt_mode']=hvm
)



## DEFAULT QVM-SERVICES
declare -rA DEFAULT_STA_SERVICES=()
#    ['updates_proxy_enabled']=true
#)
declare -rA DEFAULT_TPL_SERVICES=()
declare -rA DEFAULT_APP_SERVICES=()
declare -rA DEFAULT_NDP_SERVICES=()



## DEFAULT QVM-FEATURES
declare -rA DEFAULT_STA_FEATURES=()
declare -rA DEFAULT_TPL_FEATURES=()
declare -rA DEFAULT_APP_FEATURES=()
declare -rA DEFAULT_NDP_FEATURES=()
