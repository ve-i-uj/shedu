#!/bin/bash
# Stop the game.

# We don't need containers because the db has its own docker volume
# and apps don't store state.
echo "Delete containers ..."
docker-compose rm -fsv
