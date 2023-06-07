# Constants for bash scripts of the project.

# Эта переменная должна быть выставлена в окружении. По ней будут сформированы
# уникальные имена для образов и контейнеров инфраструктуры. Других переменных
# конфиг не ждёт. Переменные в данном конфиге или константы или вычисляются
# на основе других переменных в этом конфиге + GAME_UNIQUE_NAME
export GAME_UNIQUE_NAME=$GAME_UNIQUE_NAME

_curr_dir=$( realpath "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"/.. )
export _curr_dir=$_curr_dir  # С этой строкой PROJECT_DIR корректно прописывается envsubst (?)
export PROJECT_DIR="$_curr_dir"
export SCRIPTS="$PROJECT_DIR/scripts"

export PROJECT_NAME=shedu
export PROJECT_CACHE_DIR=/tmp/shedu
export GAME_COMPOSE_PROJECT_NAME=$GAME_UNIQUE_NAME
export ELK_COMPOSE_PROJECT_NAME=kbe-elk

# Для игр используется один и тот же образ KBE, привязанный к коммиту KBE
export KBE_COMPILED_IMAGE_NAME="$PROJECT_NAME/kbe-compiled"

export PRE_ASSETS_IMAGE_NAME="$PROJECT_NAME/kbe-pre-assets"

export KBE_ENKI_PYTHON_IMAGE_NAME=$PROJECT_NAME/enki-python

export KBE_ASSETS_IMAGE_NAME=$PROJECT_NAME/kbe-assets-$GAME_UNIQUE_NAME
export KBE_ASSETS_CONTAINER_NAME=kbe-assets-$GAME_UNIQUE_NAME

export KBE_COMPONENT_IMAGE_NAME=$PROJECT_NAME/kbe-game-$GAME_UNIQUE_NAME
export KBE_COMPONENT_CONTAINER_NAME=kbe-game

export KBE_DB_IMAGE_NAME=mariadb:10.8
export KBE_DB_IMAGE_TAGGED_NAME=$PROJECT_NAME/$KBE_DB_IMAGE_NAME
export KBE_DB_CONTAINER_NAME=kbe-game-mariadb

# Тома будут создавать и удалять в ручную в правиле сборки. Это нужно, т.к.
# ELK и игра находятся в разных сетях и описываются разными docker-compose.yml
# файлами. Но у них общий том для записи и чтения логов.
# Если в правиле очистки _игры_ не будет найден том для ELK - это будет
# означать, что нужно удалить и том с логами. Аналогично и с случае с очисткой
# ELK - игра вычищена, значит и том с логами больше не нужен.
export KBE_DB_VOLUME_NAME=kbe-mariadb-$GAME_UNIQUE_NAME-data
export KBE_LOG_VOLUME_NAME=kbe-log-data
export ELK_ES_VOLUME_NAME=kbe-elastic-data

export KBE_NET_NAME="kbe-net"

export DOCKERFILE_KBE_ASSETS="$PROJECT_DIR/dockerfiles/kbengine/Dockerfile.assets"
export DOCKERFILE_KBE_COMPILED=dockerfiles/kbengine/Dockerfile.kbe-compiled
export DOCKERFILE_PRE_ASSETS=dockerfiles/kbengine/Dockerfile.pre-assets
export DOCKERFILE_COCOS_DEMO_CLIENT=dockerfiles/kbengine/Dockerfile.cocos-demo
export DOCKERFILE_ENKI_PYTHON=dockerfiles/kbengine/Dockerfile.enki

export KBE_ASSETS_DEMO_GIT_URL=https://github.com/kbengine/kbengine_demos_assets.git
export KBE_GITHUB_URL=https://github.com/kbengine/kbengine

export KBE_GITHUB_API_URL=https://api.github.com/repos/kbengine/kbengine

export KBE_COCOS_JS_DEMO_GIT_URL=https://github.com/kbengine/kbengine_cocos2d_js_demo.git

export DOC_CONFIG_URL=https://github.com/ve-i-uj/shedu

# ElasticSearch + LogStash + Kibana

export ELK_VERSION=8.5.3
export ELK_PROJECT_NAME=kbe-log-elk

export ELK_I_NAME_PREFIX=$PROJECT_NAME/$ELK_PROJECT_NAME
export ELK_C_NAME_PREFIX=$ELK_PROJECT_NAME

export ELK_ES_IMAGE_NAME=elasticsearch:$ELK_VERSION
export ELK_ES_IMAGE_TAG=$ELK_I_NAME_PREFIX-elastic:$ELK_VERSION
export ELK_ES_CONTATINER_NAME=$ELK_C_NAME_PREFIX-elastic

export ELK_LOGSTASH_IMAGA_NAME=logstash:$ELK_VERSION
export ELK_LOGSTASH_IMAGE_TAG=$ELK_I_NAME_PREFIX-logstash:$ELK_VERSION
export ELK_LOGSTASH_CONTATINER_NAME=$ELK_C_NAME_PREFIX-logstash

export ELK_KIBANA_IMAGA_NAME=kibana:$ELK_VERSION
export ELK_KIBANA_IMAGE_TAG=$ELK_I_NAME_PREFIX-kibana:$ELK_VERSION
export ELK_KIBANA_CONTATINER_NAME=$ELK_C_NAME_PREFIX-kibana

export ELK_DEJAVU_IMAGA_NAME=appbaseio/dejavu:3.6.1
export ELK_DEJAVU_IMAGE_TAG=$ELK_I_NAME_PREFIX-dejavu:3.6.1
export ELK_DEJAVU_CONTATINER_NAME=$ELK_C_NAME_PREFIX-dejavu

export KBE_DEMO_COCOS_CLIENT_IMAGE_NAME=$PROJECT_NAME/kbe-cocos-demo-client
export KBE_DEMO_COCOS_CLIENT_CONTAINER_NAME=kbe-cocos-demo-client
