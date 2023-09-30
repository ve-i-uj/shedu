# Обновить библиотеку Enki из локальной папки.
#
# Скрипт используется в разработке, например, в tasks.json для VSCode перед сборкой.
# Библиотека обновляется только, если выставлена переменная ENKI_PATH.
# ENKI_PATH выставляется в конфиге (см. configs/example.env).

curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir/../init.sh" )
source $( realpath $SCRIPTS/log.sh )

$SCRIPTS/misc/check_config.sh "$PROJECT_DIR/.env" @>/dev/null
if [ $? -ne 0 ]; then
    log error "Invalid config file (shedu/.env). Run \"make check_config\" "
    exit 1
fi

source $PROJECT_DIR/.env

if [ ! -z "${ENKI_PATH-}" ]; then
    log info "Remove \"$PROJECT_DIR/enki\""
    rm -rf "$PROJECT_DIR/enki"
    cp -r "${ENKI_PATH}" "$PROJECT_DIR/enki"
    log info "The library \"enki\" has been update (the source path is \"${ENKI_PATH}\")"
else
    log info "The variable \"ENKI_PATH\" is not set. Nothing to update"
fi
