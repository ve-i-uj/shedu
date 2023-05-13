#!/bin/bash
# Check a configuration file of the project.

curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir"/../init.sh )
source $( realpath $SCRIPTS/log.sh )

USAGE="The script checks a configuration file of the project. \
Use absolute path to the configuration file in the first argument.

Usage: bash $0 $PROJECT_DIR/configs/<YOUR CONFIG NAME>.env
"

required_vars=(
    "MYSQL_ROOT_PASSWORD"
    "MYSQL_DATABASE"
    "MYSQL_USER"
    "MYSQL_PASSWORD"
    "KBE_ASSETS_PATH"
    "KBE_ASSETS_VERSION"
    "GAME_UNIQUE_NAME"
)

optional_vars=(
    "KBE_GIT_COMMIT"
    "KBE_USER_TAG"
    "KBE_ASSETS_SHA"
    "KBE_KBENGINE_XML_ARGS"
    "GAME_IDLE_START"
)

# The example config file contains all necessary variable. Read all variable
# names from it.
all_vars=()
while IFS= read -r line; do
    case $line in
        ''|\#*) continue ;;
    esac
    all_vars+=( $(echo "$line" | cut -d= -f1) )
done < configs/example.env

config_path="${1:-}"

log info "Check the config file \"$config_path\""

if [ -z "$config_path" ]; then
    log error "No config file in the first argument"
    exit 1
fi

if [ ! -f "$config_path" ]; then
    log warn "The config file \"shedu/.env\" does not exist. Run \"make help\""
    exit 1
fi

# Чтобы здесь в скрипте можно было получать значения его переменных
source "$config_path"

error=false
for var_name in "${all_vars[@]}"; do
    if [[ " ${optional_vars[*]} " =~ " ${var_name} " ]] && [ -z "${!var_name:-}" ]; then
        log info "\"$var_name\" - unset (it's an optional variable)"
        continue
    fi
    if [[ " ${required_vars[*]} " =~ " ${var_name} " ]] && [ -z "${!var_name:-}" ]; then
        log warn "\"$var_name\" - unset (non-empty value is required)"
        error=true
        continue
    fi
    if [ -z "${!var_name:-}" ]; then
        log warn "\"$var_name\" - unset"
        error=true
        continue
    fi
done

if [ ! -z "$KBE_GIT_COMMIT" ]; then
    log info "Chech KBE_GIT_COMMIT ..."
    bash $SCRIPTS/misc/is_kbe_commit.sh $KBE_GIT_COMMIT
fi

if [ ! -z "$KBE_ASSETS_PATH" ] && [ "$KBE_ASSETS_PATH" != "demo" ] && [ ! -d "$KBE_ASSETS_PATH" ]; then
    log warn "\"KBE_ASSETS_PATH\" - There is NO directory \"$KBE_ASSETS_PATH\""
fi


if [ "$error" == true ]; then
    exit 1
fi

log info "The config file is Ok"
exit 0
