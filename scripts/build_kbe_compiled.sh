#!/bin/bash

USAGE="
Usage. Build a docker image of the compiled KBEngine.
The \"force\" flag to build a new image from the kbe source code without cache \
(an image on the hub or the host).
Example:
bash $0 \\
  --kbe-git-commit=7d379b9f \\
  --kbe-compiled-image-name-sha=0b27c18a \\
  --kbe-compiled-image-name-1=v1.3.8-0b27c18a \\
  [--force]
"

curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir/init.sh" )
source $( realpath $SCRIPTS/log.sh )

log info "Build a docker image of compiled KBEngine ..."

log debug "Parse CLI arguments ..."
kbe_git_commit=""
kbe_compiled_image_name_sha=""
kbe_compiled_image_name_1=""
help=false
force=false
for arg in "$@"
do
    key=$( echo "$arg" | cut -f1 -d= )
    value=$( echo "$arg" | cut -f2 -d= )

    case "$key" in
        --kbe-git-commit)   kbe_git_commit=${value} ;;
        --kbe-compiled-image-name-sha)   kbe_compiled_image_name_sha=${value} ;;
        --kbe-compiled-image-name-1) kbe_compiled_image_name_1=${value} ;;
        --force)    force=true ;;
        --help) help=true ;;
        -h) help=true ;;
        *)
    esac
done

if [ "$help" = true ]; then
    echo -e "$USAGE"
    exit 0
fi

if [ -z "$kbe_git_commit" ] || [ -z "$kbe_compiled_image_name_1" ] || [ -z "$kbe_compiled_image_name_sha" ]; then
    log error "Not all arguments passed"
    exit 1
fi

if ! $force; then
    if [ ! -z $(docker images -q "$kbe_compiled_image_name_sha") ]; then
        log info "The \"$kbe_compiled_image_name_sha\" image already exists at the host. Exit"
        docker tag "$kbe_compiled_image_name_sha" "$kbe_compiled_image_name_1"
        exit 0
    fi
    log info "There is NO image \"$kbe_compiled_image_name_sha\" at the host"

    log info "Trying to find the \"$kbe_compiled_image_name_sha\" image on the docker hub ..."
    if docker manifest inspect $kbe_compiled_image_name_sha >/dev/null 2>&1; then
        log info "The image is found. Download the \"$kbe_compiled_image_name_sha\" image ..."
        docker pull "$kbe_compiled_image_name_sha"
        docker tag "$kbe_compiled_image_name_sha" "$kbe_compiled_image_name_1"
        log info "The \"$kbe_compiled_image_name_sha\" image was downloaded from the docker hub. Exit"
        exit 0
    fi
    log info "There is NO image \"$kbe_compiled_image_name_sha\" on the docker hub"
fi

log info "Build the \"$kbe_compiled_image_name_sha\" image ..."
docker build \
    --file "$DOCKERFILE_KBE_COMPILED" \
    --build-arg COMMIT_SHA="$kbe_git_commit" \
    --tag "$kbe_compiled_image_name_sha" \
    --tag "$kbe_compiled_image_name_1" \
    .

log info "Done ($0)"
