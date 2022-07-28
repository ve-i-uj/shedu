# Constants for bash scripts of the project.

_curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROJECT_DIR=$( realpath "$_curr_dir/.." )
PROJECT_NAME=$( basename "$PROJECT_DIR" )

SCRIPTS="$PROJECT_DIR/scripts"

PRE_ASSETS_IMAGE_NAME="$PROJECT_NAME/kbe-compiled"
ASSETS_IMAGE_NAME="$PROJECT_NAME/kbe-assets"
IMAGE_NAME_ASSETS="$PROJECT_NAME/kbe-assets"
IMAGE_NAME_KBE_COMPILED="$PROJECT_NAME/kbe-compiled"
IMAGE_NAME_PRE_ASSETS="$PROJECT_NAME/kbe-pre-assets"

KBE_DOCKERFILE_PATH="$PROJECT_DIR/dockerfiles/kbengine/Dockerfile.kbe"
ASSETS_DOCKERFILE_PATH="$PROJECT_DIR/dockerfiles/kbengine/Dockerfile.assets"
DOCKERFILE_KBE_ASSETS="$PROJECT_DIR/dockerfiles/kbengine/Dockerfile.assets"
DOCKERFILE_KBE_COMPILED="$PROJECT_DIR/dockerfiles/kbengine/Dockerfile.kbe-compiled"
DOCKERFILE_PRE_ASSETS="$PROJECT_DIR/dockerfiles/kbengine/Dockerfile.pre-assets"

KBE_ASSETS_CONTAINER_NAME=kbe-assets

KBE_ASSETS_DEMO_URL=https://github.com/kbengine/kbengine_demos_assets.git
DOC_CONFIG_URL=https://github.com/ve-i-uj/shedu
