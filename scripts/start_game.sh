#!/bin/bash
# Start the built game.

# Import global constants of the project
curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir/init.sh" )

USAGE="
bash $0 \\
  --assets-path=/tmp/assets \\
  --assets-image=v0.0.1
"

echo "[DEBUG] Parse CLI arguments ..."
assets_path=""
assets_image=""
help=false
for arg in "$@"
do
    key=$( echo "$arg" | cut -f1 -d= )
    value=$( echo "$arg" | cut -f2 -d= )
    case "$key" in
        --assets-path)  assets_path=${value} ;;
        --assets-image)   assets_image=${value} ;;
        --help)         help=true ;;
        -h)             help=true ;;
        *)
    esac
done

if [ "$help" = true ]; then
    echo -e "$USAGE"
    exit 0
fi

if [ -z "$assets_path" ] || [ -z "$assets_image" ]; then
    echo "[ERROR] Not all arguments passed" >&2
    echo -e "$USAGE"
    exit 1
fi

echo "[DEBUG] Check the \"$assets_image\" image exists"
existed=$(docker images --filter reference="$assets_image" -q)
if [ -z "$existed"  ]; then
    echo -e "[ERROR] There is NO \"$assets_image\" image. Build assets at first."
    exit 1
fi
echo "[INFO] The game image exists"

cd "$PROJECT_DIR"
export KBE_ASSETS_IMAGE_NAME="$assets_image"
echo "[INFO] Delete old containers"
docker-compose rm -fs kbe-mariadb >/dev/null
docker-compose rm -fs kbe-assets >/dev/null
echo "[INFO] Start the assets container (from \"$assets_image\") ..."
docker-compose up -d kbe-mariadb
docker-compose up -d kbe-assets

echo "[INFO] Done ($0)"
