SHELL := /bin/bash

include contrib/colors.mk

project := $(shell basename $$(pwd))

config ?=
ifneq ("$(wildcard $(config))","")
	include $(config)
	export $(shell sed 's/=.*//' $(config))
endif

ifeq ($(KBE_GIT_COMMIT),)
	override KBE_GIT_COMMIT := $(shell scripts/misc/get_latest_kbe_sha.sh)
endif

.PHONY : all help build_kbe clean build_game start_game list version

.DEFAULT:
	@echo Use \"make help\"

.check-config:
ifeq (,$(wildcard $(config)))
	$(error [ERROR] No config file. Use "make help")
endif

.check-git-sha:
ifeq ($(KBE_GIT_COMMIT),)
	$(error [ERROR] No kbe git commit (no value in the variable "KBE_GIT_COMMIT" \
	and the script cannot request the latest sha))
endif

all: build

build: build_kbe build_game  ## Build a game (config file required)
	@echo -e "\nDone.\n"

build_kbe: .check-config .check-git-sha  ## Build a docker image of KBEngine (config file required)
	@scripts/build_kbe.sh \
		--git-commit=$(KBE_GIT_COMMIT) \
		--user-tag=$(KBE_USER_TAG)

build_game: .check-config .check-git-sha build_kbe  ## Build a kbengine docker image contained assets. It binds "assets" with the built kbengine image (config file required)
	@scripts/build_assets.sh \
		--kbe-git-commit=$(KBE_GIT_COMMIT) \
		--kbe-user-tag=$(KBE_USER_TAG) \
		--assets-path=$(KBE_ASSETS_PATH) \
		--assets-version=$(KBE_ASSETS_VERSION) \
		# > /dev/null

start_game: .check-config build_game  ## Run the docker image contained the game (config file required)
	@scripts/start_game.sh \
		--kbe-git-commit=$(KBE_GIT_COMMIT) \
		--kbe-user-tag=$(KBE_USER_TAG) \
		--assets-path=$(KBE_ASSETS_PATH) \
		--assets-version=$(KBE_ASSETS_VERSION)

stop_game:  ## Stop the docker container contained the game
	@scripts/stop_game.sh > /dev/null

game_status:  ## Return the game status ("running" or "stopped")
	@scripts/get_game_status.sh

clean:  ## Delete artefacts connected with the projects (containers, volumes, docker networks, etc)
	@scripts/clean.sh \
		--kbe-git-commit=$(KBE_GIT_COMMIT) \
		--kbe-user-tag=$(KBE_USER_TAG) \
		--assets-path=$(KBE_ASSETS_PATH) \
		--assets-version=$(KBE_ASSETS_VERSION) \

define HELP_TEXT
*** [$(project)] Help ***

The project builds, packages and starts kbengine and kbe environment in the docker containers.

Some rules required a config file. Use path to the config file in the "config" \
cli argument. The build of the project will be aborted if no "config" argument \
or the file doesn't exist. For more information visit the page <https://github.com/ve-i-uj/shedu>

Example:
make build config=configs/example.env

endef

export HELP_TEXT
help:  ## This help
	@echo "$$HELP_TEXT"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $$(echo $(MAKEFILE_LIST) | cut -d " " -f1) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "%-15s %s\n", $$1, $$2}'
	@echo

# Debug rules

go_into:  ## [Debug] Go into the running game container
	@scripts/misc/go_into_container.sh

check_config: .check-config  ## [Debug] Check configuration file (config file required)
	@scripts/misc/check_config.sh $(config) > /dev/null

version:  ## [Debug] Current version of the project
	@scripts/version/get_version.sh

print:  ## [Debug] List built kbe images
	@echo -e "Built kbe images:"
	@scripts/misc/list_images.sh
	@echo

logs:  ## [Debug] Show actual log records of the game (config file required)
	-@scripts/misc/tail_logs.sh \
		--kbe-git-commit=$(KBE_GIT_COMMIT) \
		--kbe-user-tag=$(KBE_USER_TAG) \
		--assets-version=$(KBE_ASSETS_VERSION)
