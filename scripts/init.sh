# Constants for bash scripts of the project.

_curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROJECT_DIR=$( realpath "$_curr_dir/.." )
SCRIPTS_DIR=$PROJECT_DIR/scripts
DOCKERFILES_DIR=$PROJECT_DIR/dockerfiles
DOCKER_SCRIPTS_DIR=$SCRIPTS_DIR/docker
