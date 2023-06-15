# Обновить библиотеку Enki с локального хоста.
#
# Скрипт используется в разработке, например, в tasks.json для VSCode перед сборкой.
# Библиотека обновляется только, если выставлена переменная ENKI_PATH.
# ENKI_PATH выставляется в конфиге (см. configs/example.env).

curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir/../init.sh" )
source $( realpath $SCRIPTS/log.sh )
source $PROJECT_DIR/.env

if [ ! -z "${ENKI_PATH-}" ]; then
    rm -rf "$PROJECT_DIR/enki"
    cp -r "${ENKI_PATH}" "$PROJECT_DIR/enki"
    log info "The library \"enki\" has been update (the source path is \"${ENKI_PATH}\")"
else
    log debug "The variable \"ENKI_PATH\" is not set"
fi
