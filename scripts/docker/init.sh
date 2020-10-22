USER=shedu

# Directories contained Dockerfiles
PREQS_DIR=kbe-build-prerequisites
SRC_DIR=kbe-src
COMPILED_DIR=kbe-compiled
ASSETS_DIR=kbe-assets

# Image names
PREREQS_IMAGE_NAME="$USER/$PREQS_DIR"
SRC_IMAGE_NAME="$USER/$SRC_DIR:master"
COMPILED_IMAGE_NAME="$USER/$COMPILED_DIR:master"
ASSETS_IMAGE_NAME="$USER/$ASSETS_DIR"

