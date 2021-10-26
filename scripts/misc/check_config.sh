#!/bin/bash
# Check a configuration file of the project.

# Import global constants of the project
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir"/../init.sh )

USAGE="The script checks a configuration file of the project. \
Use absolute path to the configuration file in the first argument.

Usage: bash $0 $PROJECT_DIR/configs/example.env
"

required_vars=(KBE_ASSETS_PATH KBE_ASSETS_VERSION)
optional_vars=(KBE_GIT_COMMIT KBE_USER_TAG)

# The example config file contains all necessary variable. Let get all variable
# names from it.
all_vars=()
while IFS= read -r line; do
    case $line in
        ''|\#*) continue ;;         # skip blank lines and lines starting with #
    esac
    all_vars+=( $(echo "$line" | cut -d= -f1) )
done < configs/example.env

config_path="$1"

if [ -z "$config_path" ]; then
    echo "[ERROR] No config file in the first argument" >&2
    echo "$USAGE"
    exit 1
fi

if [ ! -f "$config_path" ]; then
    echo "[ERROR] The config file does not exist (path = \"$config_path\")" >&2
    echo "$USAGE"
    exit 1
fi

source "$config_path"

error=false
for var_name in "${required_vars[@]}"; do
    if [ -z "${!var_name}" ]; then
        echo "[ERROR] $var_name is unset (non-empty variable value is required)" >&2
        error=true
    fi
done

for var_name in "${all_vars[@]}"; do
    if [[ " ${required_vars[*]} " =~ " ${var_name} " ]]; then
        continue
    fi
    if [[ " ${optional_vars[*]} " =~ " ${var_name} " ]]; then
        echo "[INFO] $var_name is unset (it's an optional variable)" >&2
        continue
    fi
    if [ -z "${!var_name}" ]; then
        echo "[ERROR] $var_name is unset" >&2
        error=true
    fi
done

if [ "$error" == true ]; then
    echo "$USAGE"
    exit 1
fi

echo Ok 1>&2
