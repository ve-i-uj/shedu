# Constants for bash scripts of the project.

export GAME_UNIQUE_NAME="$GAME_UNIQUE_NAME"

_curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export PROJECT_DIR=${PROJECT_DIR:-$(realpath "$_curr_dir/..")}
export PROJECT_NAME=${PROJECT_NAME:-$(basename "$PROJECT_DIR")}
export SCRIPTS="$PROJECT_DIR/scripts"

export IMAGE_NAME_ASSETS="$PROJECT_NAME/kbe-assets-$GAME_UNIQUE_NAME"
export IMAGE_NAME_KBE_COMPILED="$PROJECT_NAME/kbe-compiled"
export IMAGE_NAME_PRE_ASSETS="$PROJECT_NAME/kbe-pre-assets-$PROJECT_NAME"

export DOCKERFILE_KBE_ASSETS="$PROJECT_DIR/dockerfiles/kbengine/Dockerfile.assets"
export DOCKERFILE_KBE_COMPILED="$PROJECT_DIR/dockerfiles/kbengine/Dockerfile.kbe-compiled"
export DOCKERFILE_PRE_ASSETS="$PROJECT_DIR/dockerfiles/kbengine/Dockerfile.pre-assets"

# In docker-compose.yml the "container_name" field has the same name.
export KBE_ASSETS_CONTAINER_NAME=kbe-assets

export KBE_ASSETS_DEMO_URL=https://github.com/kbengine/kbengine_demos_assets.git
export KBE_GITHUB_URL=https://github.com/kbengine/kbengine
export KBE_GITHUB_API_URL=https://api.github.com/repos/kbengine/kbengine

export DOC_CONFIG_URL=https://github.com/ve-i-uj/shedu

# ElasticSearch + LogStash + Kibana
# TODO: Большинство переменных можно вынести в папку для ELK (легче потом будет переносить)

export ELK_VERSION=8.5.3
export COMPOSE_PROJECT_NAME=$PROJECT_NAME
export ELK_PROJECT_NAME=kbe-log-elk

export ELK_I_NAME_PREFIX=$PROJECT_NAME/$ELK_PROJECT_NAME
export ELK_C_NAME_PREFIX=$PROJECT_NAME-$ELK_PROJECT_NAME

export ELK_ES_IMAGE_NAME=elasticsearch:$ELK_VERSION
export ELK_ES_IMAGE_TAG=$ELK_I_NAME_PREFIX-elastic-$ELK_VERSION:$GAME_UNIQUE_NAME
export ELK_ES_CONTATINER_NAME=$ELK_C_NAME_PREFIX-elastic-$GAME_UNIQUE_NAME
export ELK_ES_VOLUME_NAME=$ELK_PROJECT_NAME-elastic-volume

export ELK_LOGSTASH_IMAGA_NAME=logstash:$ELK_VERSION
export ELK_LOGSTASH_IMAGE_TAG=$ELK_I_NAME_PREFIX-logstash-$ELK_VERSION:$GAME_UNIQUE_NAME
export ELK_LOGSTASH_CONTATINER_NAME=$ELK_C_NAME_PREFIX-logstash-$GAME_UNIQUE_NAME

export ELK_FILEBEAT_DOCKERFILE="$PROJECT_DIR/dockerfiles/elk/Dockerfile.filebeat"
export ELK_FILEBEAT_IMAGE_TAG=$ELK_I_NAME_PREFIX-filebeat-$ELK_VERSION:$GAME_UNIQUE_NAME
export ELK_FILEBEAT_CONTATINER_NAME=$ELK_C_NAME_PREFIX-filebeat-$GAME_UNIQUE_NAME

export ELK_KIBANA_IMAGA_NAME=kibana:$ELK_VERSION
export ELK_KIBANA_IMAGE_TAG=$ELK_I_NAME_PREFIX-kibana-$ELK_VERSION:$GAME_UNIQUE_NAME
export ELK_KIBANA_CONTATINER_NAME=$ELK_C_NAME_PREFIX-kibana-$GAME_UNIQUE_NAME

export ELK_DEJAVU_IMAGA_NAME=appbaseio/dejavu
export ELK_DEJAVU_IMAGE_TAG=$ELK_I_NAME_PREFIX-dejavu:$GAME_UNIQUE_NAME
export ELK_DEJAVU_CONTATINER_NAME=$ELK_C_NAME_PREFIX-dejavu-$GAME_UNIQUE_NAME
