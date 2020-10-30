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

echo
echo "********************************"
echo "*** Docker scritps variables ***"
echo "********************************"
echo
echo "PREQS_DIR=$PREQS_DIR"
echo "SRC_DIR=$SRC_DIR"
echo "COMPILED_DIR=$COMPILED_DIR"
echo "ASSETS_DIR=$ASSETS_DIR"
echo "PREREQS_IMAGE_NAME=$PREREQS_IMAGE_NAME"
echo "SRC_IMAGE_NAME=$SRC_IMAGE_NAME"
echo "COMPILED_IMAGE_NAME=$COMPILED_IMAGE_NAME"
echo "ASSETS_IMAGE_NAME=$ASSETS_IMAGE_NAME"
echo
echo "********************************"
echo
