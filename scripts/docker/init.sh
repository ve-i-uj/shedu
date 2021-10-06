# Constants for bash scripts of the project.

curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir"/../init.sh )

PROJECT_NAME=shedu

# Directories contained Dockerfiles
PRE_BUILD_NAME=kbe-pre-build
SRC_NAME=kbe-src
LATEST_NAME=kbe-latest
COMPILED_NAME=kbe-compiled
PRE_ASSETS_NAME=kbe-pre-assets
ASSETS_NAME=kbe-assets

# Image names
PRE_BUILD_IMAGE_NAME="$PROJECT_NAME/$PRE_BUILD_NAME"
SRC_IMAGE_NAME="$PROJECT_NAME/$SRC_NAME"
LATEST_IMAGE_NAME="$PROJECT_NAME/$SRC_NAME:latest"
COMPILED_IMAGE_NAME="$PROJECT_NAME/$COMPILED_NAME"
PRE_ASSETS_IMAGE_NAME="$PROJECT_NAME/$PRE_ASSETS_NAME"
ASSETS_IMAGE_NAME="$PROJECT_NAME/$ASSETS_NAME"

# Image names
_kbe_dir="$DOCKERFILES_DIR/kbengine/kbe-engine"
_assets_dir="$DOCKERFILES_DIR/kbengine/kbe-assets"
PRE_BUILD_DOCKERFILE_PATH="$_kbe_dir/Dockerfile.$PRE_BUILD_NAME"
SRC_DOCKERFILE_PATH="$_kbe_dir/Dockerfile.$SRC_NAME"
LATEST_DOCKERFILE_PATH="$_kbe_dir/Dockerfile.$LATEST_NAME"
COMPILED_DOCKERFILE_PATH="$_kbe_dir/$COMPILED_DIR/Dockerfile.$COMPILED_NAME"
PRE_ASSETS_DOCKERFILE_PATH="$_assets_dir/Dockerfile.$PRE_ASSETS_NAME"
ASSETS_DOCKERFILE_PATH="$_assets_dir/Dockerfile.$ASSETS_NAME"
