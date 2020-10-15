# Constants for bash scripts of the project.

curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROJECT_DIR=`realpath $curr_dir/..`

SCRIPTS_DIR=$PROJECT_DIR/scripts
DOCKERFILES_DIR=$PROJECT_DIR/dockerfiles

DOCKER_SCRIPTS_DIR=$SCRIPTS_DIR/docker

