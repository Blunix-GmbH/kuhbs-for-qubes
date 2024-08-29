# Merge associative arrays

# Merge qvm-prefs
declare -p STA_PREFS >/dev/null 2>&1 || declare -rA STA_PREFS=()
declare -p TPL_PREFS >/dev/null 2>&1 || declare -rA TPL_PREFS=()
declare -p APP_PREFS >/dev/null 2>&1 || declare -rA APP_PREFS=()
declare -p NDP_PREFS >/dev/null 2>&1 || declare -rA NDP_PREFS=()
eval declare -rA use_sta_prefs=($(declare -p DEFAULT_STA_PREFS STA_PREFS | sed -z -e $'s/declare[^(]*(//g' -e $'s/)[^ ]//g'))
eval declare -rA use_tpl_prefs=($(declare -p DEFAULT_TPL_PREFS TPL_PREFS | sed -z -e $'s/declare[^(]*(//g' -e $'s/)[^ ]//g'))
eval declare -rA use_app_prefs=($(declare -p DEFAULT_APP_PREFS APP_PREFS | sed -z -e $'s/declare[^(]*(//g' -e $'s/)[^ ]//g'))
eval declare -rA use_ndp_prefs=($(declare -p DEFAULT_NDP_PREFS NDP_PREFS | sed -z -e $'s/declare[^(]*(//g' -e $'s/)[^ ]//g'))

# Merge qvm-services
declare -p STA_SERVICES >/dev/null 2>&1 || declare -rA STA_SERVICES=()
declare -p TPL_SERVICES >/dev/null 2>&1 || declare -rA TPL_SERVICES=()
declare -p APP_SERVICES >/dev/null 2>&1 || declare -rA APP_SERVICES=()
declare -p NDP_SERVICES >/dev/null 2>&1 || declare -rA NDP_SERVICES=()
eval declare -rA use_sta_services=($(declare -p DEFAULT_STA_SERVICES STA_SERVICES | sed -z -e $'s/declare[^(]*(//g' -e $'s/)[^ ]//g'))
eval declare -rA use_tpl_services=($(declare -p DEFAULT_TPL_SERVICES TPL_SERVICES | sed -z -e $'s/declare[^(]*(//g' -e $'s/)[^ ]//g'))
eval declare -rA use_app_services=($(declare -p DEFAULT_APP_SERVICES APP_SERVICES | sed -z -e $'s/declare[^(]*(//g' -e $'s/)[^ ]//g'))
eval declare -rA use_ndp_services=($(declare -p DEFAULT_NDP_SERVICES NDP_SERVICES | sed -z -e $'s/declare[^(]*(//g' -e $'s/)[^ ]//g'))

# Merge qvm-features
declare -p STA_FEATURES >/dev/null 2>&1 || declare -rA STA_FEATURES=()
declare -p TPL_FEATURES >/dev/null 2>&1 || declare -rA TPL_FEATURES=()
declare -p APP_FEATURES >/dev/null 2>&1 || declare -rA APP_FEATURES=()
declare -p NDP_FEATURES >/dev/null 2>&1 || declare -rA NDP_FEATURES=()
eval declare -rA use_sta_features=($(declare -p DEFAULT_STA_FEATURES STA_FEATURES | sed -z -e $'s/declare[^(]*(//g' -e $'s/)[^ ]//g'))
eval declare -rA use_tpl_features=($(declare -p DEFAULT_TPL_FEATURES TPL_FEATURES | sed -z -e $'s/declare[^(]*(//g' -e $'s/)[^ ]//g'))
eval declare -rA use_app_features=($(declare -p DEFAULT_APP_FEATURES APP_FEATURES | sed -z -e $'s/declare[^(]*(//g' -e $'s/)[^ ]//g'))
eval declare -rA use_ndp_features=($(declare -p DEFAULT_NDP_FEATURES NDP_FEATURES | sed -z -e $'s/declare[^(]*(//g' -e $'s/)[^ ]//g'))
