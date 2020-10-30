# Constants for bash scripts of the project.

_curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROJECT_DIR=`realpath $_curr_dir/..`

SCRIPTS_DIR=$PROJECT_DIR/scripts
DOCKERFILES_DIR=$PROJECT_DIR/dockerfiles

DOCKER_SCRIPTS_DIR=$SCRIPTS_DIR/docker

echo
echo "********************************"
echo "*** Common scritps variables ***"
echo "********************************"
echo
echo "PROJECT_DIR=$PROJECT_DIR"
echo "SCRIPTS_DIR=$SCRIPTS_DIR"
echo "DOCKERFILES_DIR=$DOCKERFILES_DIR"
echo "DOCKER_SCRIPTS_DIR=$DOCKER_SCRIPTS_DIR"
echo
echo "********************************"
echo
