SHELL := /bin/bash

project := $(shell basename $$(pwd))

config ?= $(shell realpath .env)
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

.check-git-sha:
ifeq ($(KBE_GIT_COMMIT),)
	$(error [ERROR] No kbe git commit (no value in the variable "KBE_GIT_COMMIT" \
	and the script cannot request the latest sha))
endif

.check-config:
ifeq (,$(wildcard $(config)))
	$(error [ERROR] No file "$(config)". Use "make help")
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

The main goal of the project is to simplify kbengine deploy. It doesn't need \
to know how to build a C++ project or what library you need to install for. \
Moreover all kbe infrastructure (database, smtp server etc) can be built and started \
just in one command too. You can choose a kbe commit for your kbe build and easy \
link assets to the chosen kbe version. Change variables in "configs/example.env" \
and save the file like a new one with your configuration.

Some rules required a config file. Use path to the config file in the "config" \
cli argument. Example:
make build config=configs/example.env

If no "config" argument presented it try to read .env file from the root \
directory of the project. \
The build of the project will be aborted if no "config" argument or the file \
doesn't exist.

endef

export HELP_TEXT
help:  ## This help
	@echo "$$HELP_TEXT"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $$(echo ${MAKEFILE_LIST} | cut -d " " -f1) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "%-15s %s\n", $$1, $$2}'
	@echo
