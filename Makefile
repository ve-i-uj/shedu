SHELL := /bin/bash

include contrib/colors.mk

project := $(shell basename $$(pwd))

# Check the .env file exists
ifneq ("$(wildcard .env)","")
	include .env
	export $(shell sed 's/=.*//' .env)
endif

ifeq ($(KBE_GIT_COMMIT),)
	override KBE_GIT_COMMIT := $(shell scripts/misc/get_latest_kbe_sha.sh)
		ifeq ($(KBE_GIT_COMMIT),)
			override KBE_GIT_COMMIT := 7d379b9f
		endif
endif

.PHONY : all help build_kbe clean build_game start list version

.DEFAULT:
	@echo Use \"make help\"

.check-config:
ifeq (,$(wildcard .env))
	$(error [ERROR] No config file "$(project)/.env". Use "make help")
endif

all: build

build: build_kbe build_game  ## Build all
	@echo -e "\nDone.\n"

build_kbe: .check-config ## Build a docker image of KBEngine
	@scripts/build/build_kbe_compiled.sh \
		--kbe-git-commit=$(KBE_GIT_COMMIT) \
		--kbe-user-tag=$(KBE_USER_TAG)

build_game: .check-config  ## Build a kbengine docker image contained assets. It binds "assets" with the built kbengine image
	@scripts/build/build_pre_assets.sh
	@scripts/build/build_assets.sh \
		--kbe-git-commit=$(KBE_GIT_COMMIT) \
		--kbe-user-tag=$(KBE_USER_TAG) \
		--kbe-assets-sha=$(KBE_ASSETS_SHA) \
		--assets-path=$(KBE_ASSETS_PATH) \
		--assets-version=$(KBE_ASSETS_VERSION) \
		--env-file=.env \
		--kbengine-xml-args=$(kbengine_xml_args)

start: .check-config  ## Run the docker image contained the game
	@scripts/start_game.sh \
		--kbe-git-commit=$(KBE_GIT_COMMIT) \
		--kbe-user-tag=$(KBE_USER_TAG) \
		--assets-path=$(KBE_ASSETS_PATH) \
		--assets-version=$(KBE_ASSETS_VERSION)

stop:  ## Stop the docker container contained the game
	@scripts/stop_game.sh > /dev/null

status:  ## Return the game status ("running" or "stopped")
	@scripts/get_game_status.sh

clean: .check-config  ## Delete artefacts connected with the projects (containers, volumes, docker networks, etc)
	@scripts/clean.sh \
		--kbe-git-commit=$(KBE_GIT_COMMIT) \
		--kbe-user-tag=$(KBE_USER_TAG) \
		--assets-path=$(KBE_ASSETS_PATH) \
		--assets-version=$(KBE_ASSETS_VERSION) \

build_force: .check-config ## Build a docker image of compiled KBEngine without using of cache
	@scripts/build/build_kbe_compiled.sh \
		--kbe-git-commit=$(KBE_GIT_COMMIT) \
		--kbe-user-tag=$(KBE_USER_TAG) \
		--force

define HELP_TEXT
*** [$(project)] Help ***

The project builds, packages and starts kbengine and kbe environment \
in the docker.

Some rules required a config file. Copy config from the "configs" directory \
or set your own settings in the "<project_dir>/.env" settings file.
The build of the project will be aborted if no .env file in the project \
root directory.
For more information visit the page <https://github.com/ve-i-uj/shedu>

Example:
cp configs/example.env .env
make build

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

check_config: .check-config  ## [Debug] Check configuration file
	@scripts/misc/check_config.sh .env

version:  ## [Debug] Current version of the project
	@scripts/version/get_version.sh

print:  ## [Debug] List built kbe images
	@echo -e "Built kbe images:"
	@scripts/misc/list_images.sh
	@echo

logs_console: .check_config ## [Debug] Show actual log records of the game in the console
	-@scripts/misc/tail_logs.sh \
		--kbe-git-commit=$(KBE_GIT_COMMIT) \
		--kbe-user-tag=$(KBE_USER_TAG) \
		--assets-version=$(KBE_ASSETS_VERSION)

restart: stop start

echo:
	@echo MYSQL_ROOT_PASSWORD=$(MYSQL_ROOT_PASSWORD)
