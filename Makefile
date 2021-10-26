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

ifeq ($(KBE_USER_TAG),)
	kbe_image_tag = $(KBE_GIT_COMMIT)
else
	kbe_image_tag = "$(KBE_GIT_COMMIT)-$(KBE_USER_TAG)"
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

build_game: .check-config .check-git-sha  ## Build a kbengine docker image contained assets. It binds "assets" with the built kbengine image (config file required)
	@scripts/build_assets.sh \
		--kbe-version=$(kbe_image_tag) \
		--assets-path=$(KBE_ASSETS_PATH) \
		--assets-version=$(KBE_ASSETS_VERSION)

start_game: .check-config build  ## Run the docker image contained the game (config file required)
	@scripts/start_game.sh \
		--image=$(project)/kbe-assets-$(kbe_image_tag):$(KBE_ASSETS_VERSION)

check_config: .check-config  ## Check configuration file (config file required)
	@scripts/misc/check_config.sh $(config) > /dev/null

clean:  ## Delete artefacts connected with the projects (containers, volumes, docker networks, etc)
	@scripts/clean.sh

version:  ## Current version of the project
	@scripts/version/get_version.sh

print:  ## List built kbe images
	@echo -e "Built kbe images:"
	@scripts/misc/list_images.sh
	@echo

define HELP_TEXT
*** [$(project)] Help ***

The project builds, packages and starts kbengine and kbe environment in the docker containers.

Some rules required a config file. Use path to the config file in the "config" \
cli argument. The build of the project will be aborted if no "config" argument \
or the file doesn't exist.

Example:
make build config=configs/example.env

endef

export HELP_TEXT
help:  ## This help
	@echo "$$HELP_TEXT"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $$(echo $(MAKEFILE_LIST) | cut -d " " -f1) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "%-15s %s\n", $$1, $$2}'
	@echo
