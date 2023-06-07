# Обновить библиотеку Enki с локального хоста.
#
# Скрипт используется в разработке, например, в tasks.json для VSCode перед сборкой.
# Библиотека обновляется только, если выставлена переменная ENKI_PATH.
# ENKI_PATH выставляется в конфиге (см. configs/example.env).

curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir/../init.sh" )
source $( realpath $SCRIPTS/log.sh )

if [ ! -z "${ENKI_PATH-}" ]; then
    rm -rf "$PROJECT_DIR/enki"
    cp -r "${ENKI_PATH}" "$PROJECT_DIR/enki"
fi
