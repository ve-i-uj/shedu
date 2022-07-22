#!/bin/bash
# Tail the game logs.

# Import global constants of the project
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir"/../init.sh )

USAGE="
Usage. The script shows KBEngine logs (the started game).\
 Use the image name in the first argument. Example:
bash $0 --image=$ASSETS_IMAGE_NAME-7d379b9f-v2.5.12:v0.0.1
"

echo -e "\nParse CLI arguments ..."
image=""
help=false
for arg in "$@"
do
    key=$( echo "$arg" | cut -f1 -d= )
    value=$( echo "$arg" | cut -f2 -d= )
    case "$key" in
        --image)        image=${value} ;;
        --help)         help=true ;;
        -h)             help=true ;;
        *)
    esac
done

echo "CLI arguments: "
echo "    --image=$image"

if [ -z "$image" ] || [ "$help" = true ]; then
    echo "[ERROR] Not all arguments presented"
    echo -e "$USAGE"
    exit 1
fi

bash "$curr_dir/is_running.sh"
if [ "$?" -ne 0 ]; then
    exit 1
fi

cd "$PROJECT_DIR"
export KBE_ASSETS_IMAGE="$image"
export KBE_ASSETS_CONTAINER_NAME="$KBE_ASSETS_CONTAINER_NAME"
docker-compose logs --timestamps --follow
