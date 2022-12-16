# Constants for bash scripts of the project.

export GAME_UNIQUE_NAME="${GAME_UNIQUE_NAME:-GAME_UNIQUE_NAME}"

_curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export PROJECT_DIR=$( realpath "$_curr_dir/.." )
export PROJECT_NAME=$( basename "$PROJECT_DIR" )

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

export ELK_VERSION=8.5.3

export ELK_I_NAME_PREFIX=$PROJECT_NAME/kbe-log
export ELK_C_NAME_PREFIX=$PROJECT_NAME-kbe-log

export ELK_ES_IMAGA_NAME=elasticsearch:$ELK_VERSION
export ELK_ES_IMAGE_TAG=$ELK_I_NAME_PREFIX-es-$ELK_VERSION:$GAME_UNIQUE_NAME
export ELK_ES_CONTATINER_NAME=$ELK_C_NAME_PREFIX-es-$GAME_UNIQUE_NAME

export ELK_LOGSTASH_IMAGA_NAME=logstash:$ELK_VERSION
export ELK_LOGSTASH_IMAGE_TAG=$ELK_I_NAME_PREFIX-logstash-$ELK_VERSION:$GAME_UNIQUE_NAME
export ELK_LOGSTASH_CONTATINER_NAME=$ELK_C_NAME_PREFIX-logstash-$GAME_UNIQUE_NAME

export ELK_FILEBEAT_DOCKERFILE="$PROJECT_DIR/dockerfiles/elk/Dockerfile.filebeat"
export ELK_FILEBEAT_IMAGE_TAG=$ELK_I_NAME_PREFIX-filebeat-$ELK_VERSION:$GAME_UNIQUE_NAME
export ELK_FILEBEAT_CONTATINER_NAME=$ELK_C_NAME_PREFIX-filebeat-$GAME_UNIQUE_NAME

export ELK_KIBANA_IMAGA_NAME=kibana:$ELK_VERSION
export ELK_KIBANA_IMAGE_TAG=$ELK_I_NAME_PREFIX-kibana-$ELK_VERSION:$GAME_UNIQUE_NAME
export ELK_KIBANA_CONTATINER_NAME=$ELK_C_NAME_PREFIX-kibana-$GAME_UNIQUE_NAME
