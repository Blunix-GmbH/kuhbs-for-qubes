declare -r KUHB_TYPE=app
declare -r TEMPLATE=debian-12-minimal

declare -rA APP_PREFS=(
    ["label"]=green
)

declare -r APP_BACKUP_PATHS=(
    "/home/user/todo"
    "/home/user/passnotes"
)

declare -r LAUNCHERS=(
    "user terminal 0 terminal"
)

declare -r I3_ASSIGN='assign [class="airgap"] 1'
