#!/bin/bash
# Return a game status.

curr_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $( realpath "$curr_dir/../init.sh" )
source $( realpath $SCRIPTS/log.sh )

log info "*** Game status (the current game is \"$GAME_UNIQUE_NAME\") ***"
log info

log info "* The built images:"
log info "-----"
# Сперва распечатать для текущего проекта, потом всех остальных
game_res=$( docker images --filter reference="$PROJECT_NAME/*" --format "{{.Repository}}:{{.Tag}}" | grep "$GAME_UNIQUE_NAME")
other_res=$( docker images --filter reference="$PROJECT_NAME/*" --format "{{.Repository}}:{{.Tag}}" | grep -v "$GAME_UNIQUE_NAME")
log info "The current project images:"
for name in $game_res; do
    log info "    $name"
done
log info
log info "Other:"
for name in $other_res; do
    log info "    $name"
done
log info "-----"
log info ""

log info "* The running services:"
log info "----- "
res=$( docker ps --filter name="kbe-*" --filter status=running --format "{{.Names}}" )
for name in $res; do
    log info $name
done
log info "-----"
log info ""