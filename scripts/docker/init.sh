PROJECT_NAME=shedu

# Directories contained Dockerfiles
PREREQS_DIR=kbe-build-prerequisites
SRC_DIR=kbe-src
COMPILED_DIR=kbe-compiled
ASSETS_DIR=kbe-assets

# Image names
PREREQS_IMAGE_NAME="$PROJECT_NAME/$PREREQS_DIR"
SRC_IMAGE_NAME="$PROJECT_NAME/$SRC_DIR"
COMPILED_IMAGE_NAME="$PROJECT_NAME/$COMPILED_DIR"
ASSETS_IMAGE_NAME="$PROJECT_NAME/$ASSETS_DIR"

echo
echo "********************************"
echo "*** Docker scritps variables ***"
echo "********************************"
echo
echo "PREREQS_DIR=$PREREQS_DIR"
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
