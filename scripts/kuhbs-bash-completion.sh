#/bin/bash
#
# kuhbs bash completion



# Path to kuhbs git repository
KUHBS_PATH="/home/user/kuhbs/"

# kuhbs arguments
KUHBS_ARGUMENTS="
ls
show
create
remove
backup
backup-all
restore
upgrade
upgrade-all
terminal
dump
"
# kuhbs arguments that start with a dash
KUHBS_DASH_ARGUMENTS="
-d
--debug
-v
--verbose
"




# Define completion function
_kuhbs_completions(){


    # Variables to hold the current word
    COMPREPLY=()
    local word=${COMP_WORDS[COMP_CWORD]}
    local prev=${COMP_WORDS[COMP_CWORD-1]}
    local prev2=${COMP_WORDS[COMP_CWORD-2]}
#    local prev3=${COMP_WORDS[COMP_CWORD-3]}

    # Auto-completable kuhbs information
    local kuhbs_functions="$KUHBS_ARGUMENTS"

    # Defined kuhb's
    local kuhbs_hosts="$(find $KUHBS_PATH/kuhbs/ -type f -name config.sh | sed -e "s@$KUHBS_PATH/kuhbs/@@g" -e 's@/config.sh@@g')"

    # Save qvm-ls output to only run it once (as its slow)
    qubes_vms="$(qvm-ls --raw-data --fields=name,state | sed 's/ /\n/g')"
    # Extract all VMs
    qubes_vms_all=$(echo "$qubes_vms" | cut -d '|' -f 1 | paste -sd ' ')
    # Extract all running VMs
    qubes_vms_running=$(echo "$qubes_vms" | grep Running | cut -d '|' -f 1 | paste -sd ' ')


    # kuhbs terminal has a second argument
    case "$prev2" in
        terminal)
            COMPREPLY=( $( compgen -W "user root" -- $word ) )
            return 0
            ;;
    esac


    # Process arguments
    case "$prev" in

        # No further argument options available or completable
        -d|--debug|-v|--verbose)
            COMPREPLY=()
            return 0
            ;;

        show|create|remove|backup|restore|upgrade)
            COMPREPLY=( $( compgen -W "$kuhbs_hosts" -- $word ) )
            return 0
        ;;

        terminal)
            COMPREPLY=( $( compgen -W "$qubes_vms_all" -- $word ) )
            return 0
        ;;

        dump)
            COMPREPLY=( $( compgen -W "$qubes_vms_running" -- $word ) )
            return 0
        ;;

        ls)
            return 0
        ;;

        upgrade-all)
            return 0
        ;;

        backup-all)
            return 0
        ;;

    esac


    # Complete zero arguments
    if [[ ${word} == "" ]]; then
        COMPREPLY=($(compgen -W "$KUHBS_DASH_ARGUMENTS $KUHBS_ARGUMENTS" -- $word ) )
        return 0

    # Complete argument starting with a-z
    elif [[ ${word} =~ ^[A-Za-z0-9] ]]; then
        COMPREPLY=($(compgen -W "$KUHBS_ARGUMENTS" -- $word ) )
        return 0

    # Complete argument starting with dash
    elif [[ ${word} == -* ]]; then
        COMPREPLY=($(compgen -W "$KUHBS_DASH_ARGUMENTS" -- $word ) )
        return 0

    fi


}



# Activate completion function
complete -F _kuhbs_completions kuhbs
