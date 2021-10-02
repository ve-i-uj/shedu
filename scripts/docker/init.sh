# Constants for bash scripts of the project.

curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir"/../init.sh )

PROJECT_NAME=shedu

# Directories contained Dockerfiles
PREREQS_DIR=kbe-build-prerequisites
SRC_DIR=kbe-src
LATEST_DIR=kbe-latest
COMPILED_DIR=kbe-compiled
ASSETS_DIR=kbe-assets

# Image names
PREREQS_IMAGE_NAME="$PROJECT_NAME/$PREREQS_DIR"
SRC_IMAGE_NAME="$PROJECT_NAME/$SRC_DIR"
LATEST_IMAGE_NAME="$PROJECT_NAME/$SRC_DIR:latest"
COMPILED_IMAGE_NAME="$PROJECT_NAME/$COMPILED_DIR"
ASSETS_IMAGE_NAME="$PROJECT_NAME/$ASSETS_DIR"

# Image names
PREREQS_DOCKERFILE_PATH="$DOCKERFILES_DIR/kbengine/$PREREQS_DIR/Dockerfile"
SRC_DOCKERFILE_PATH="$DOCKERFILES_DIR/kbengine/$SRC_DIR/Dockerfile"
LATEST_DOCKERFILE_PATH="$DOCKERFILES_DIR/kbengine/$LATEST_DIR/Dockerfile"
COMPILED_DOCKERFILE_PATH="$DOCKERFILES_DIR/kbengine/$COMPILED_DIR/Dockerfile"
ASSETS_DOCKERFILE_PATH="$DOCKERFILES_DIR/kbengine/$ASSETS_DIR/Dockerfile"
