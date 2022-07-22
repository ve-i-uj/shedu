#!/bin/bash
# Start the built game.

# Import global constants of the project
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir/init.sh" )

USAGE="
Usage. The script runs the game docker image (compiled KBEngine + assets).\
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

echo "It needs \"$image\" image. Checking this docker image exists ..."
existed=$(docker images --filter reference="$image" -q)
if [ -z "$existed"  ]; then
    echo -e "[ERROR] There is NO \"$image\" image. Use \"build_assets.sh\" at first."
    choice_set=$(docker images --filter reference="$ASSETS_IMAGE_NAME-*" --format "{{.Repository}}:{{.Tag}}")
    if [ -z "$choice_set" ]; then
        choice_set="(no images)"
    fi
    echo -e "\nAvailable assets images:\n$choice_set"
    echo "$USAGE"
    exit 1
fi
echo "[INFO] The game image exists"

cd "$PROJECT_DIR"
export KBE_ASSETS_IMAGE="$image"
export KBE_ASSETS_CONTAINER_NAME="$KBE_ASSETS_CONTAINER_NAME"
echo "[INFO] Delete old containers ..."
docker-compose rm -fsv
echo "[INFO] Start the assets container (from \"$image\") ..."
docker-compose up -d

echo "[INFO] Done ($0)"
