curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir"/../init.sh )
source $( realpath $SCRIPTS/log.sh )

only_user_settings=false
arg1="${1:-}"
if [ "$arg1" = "--only-user-settings" ]; then
    only_user_settings=true
fi


log info
log info "*** These variables are being used in the project scripts ***"
log info

log info "-----"
log info "* The variables of the \".env\" file (the user settings):"
log info "-----"

all_vars=()
while IFS= read -r line; do
    case $line in
        ''|\#*) continue ;;
    esac
    all_vars+=( $( echo "$line" | cut -d= -f1 ) )
done < $PROJECT_DIR/configs/example.env

for var_name in "${all_vars[@]}"; do
    log info "    $var_name=${!var_name:-}"
done
log info "-----"
log info

if $only_user_settings; then
    exit 0
fi

log info ""
log info "-----"
log info "* The variables of the \"init.sh\" file (the internal scripts settings):"
log info "-----"

all_vars=()
while IFS= read -r line; do
    case $line in
        ''|\#*) continue ;;
    esac
    all_vars+=( $( echo "$line" | grep '^export' | cut -d= -f1 | cut -c8- ) )

done < $SCRIPTS/init.sh

for var_name in "${all_vars[@]}"; do
    log info "    $var_name=${!var_name}"
done
log info "-----"
log info
