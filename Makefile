SHELL := /bin/bash

ROOT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
SCRIPTS := $(ROOT_DIR)/scripts
ELK_SCRIPTS := $(SCRIPTS)/elk

# Check the .env file exists
ifneq ("$(wildcard .env)","")
	include .env
	export $(shell sed 's/=.*//' .env)
endif

# Если хэш целевого комита не выставлен, то берётся последний комит из репозитория
KBE_GIT_COMMIT := $(KBE_GIT_COMMIT)
ifeq ($(KBE_GIT_COMMIT),)
	override KBE_GIT_COMMIT := $(shell scripts/misc/get_latest_kbe_sha.sh)
		ifeq ($(KBE_GIT_COMMIT),)
			override KBE_GIT_COMMIT := 7d379b9f
		endif
endif

KBE_COMPILED_IMAGE_TAG_SHA := $(KBE_GIT_COMMIT)
KBE_COMPILED_IMAGE_TAG_1 := $(KBE_GIT_COMMIT)
ifneq ($(KBE_USER_TAG),)
	override KBE_COMPILED_IMAGE_TAG_1 := $(KBE_USER_TAG)-$(KBE_COMPILED_IMAGE_TAG_1)
endif

# Импорт переменых окружения из инициализационного файла, чтобы иметь
# возможность запускать здесь docker-compose
$(shell mkdir /tmp/shedu 2>/dev/null; \
	export GAME_UNIQUE_NAME=$(GAME_UNIQUE_NAME); \
	source $(SCRIPTS)/init.sh; \
	envsubst < $(SCRIPTS)/init.sh \
	| grep '^export' \
	| cut -c8- > /tmp/shedu/environment.mk \
)
include /tmp/shedu/environment.mk
export $(shell sed 's/=.*//' /tmp/shedu/environment.mk)

.PHONY: *

.DEFAULT:
	@echo Use \"make help\"

all: help

.check-config:
ifeq (,$(wildcard .env))
	$(error [ERROR] No config file "$(ROOT_DIR)/.env". Use "make help")
endif
ifeq ($(GAME_UNIQUE_NAME),)
	$(error The env. variable "GAME_UNIQUE_NAME" is undefined or empty)
endif
	@$(SCRIPTS)/misc/is_kbe_commit.sh $(KBE_GIT_COMMIT)

build: build_elk build_kbe build_game  ## Build all
	@echo -e "\nDone.\n"

start: .check-config start_elk start_game  ## Start the kbe infrastructure (DB, KBE components, ELK etc.)
	@echo -e "\nDone.\n"

stop: stop_game  ## Stop the game (the ELK is not stopping)
	@$(ROOT_DIR)/scripts/stop_game.sh

clean: .check-config  ## Delete the artefacts connected with the projects (containers, volumes, docker networks, etc)
	@$(ROOT_DIR)/scripts/clean.sh \
		--kbe-git-commit=$(KBE_GIT_COMMIT) \
		--kbe-user-tag=$(KBE_USER_TAG) \
		--assets-path=$(KBE_ASSETS_PATH) \
		--assets-version=$(KBE_ASSETS_VERSION) \

restart: stop start  ## Stop and start

status:  ## Return the game status ("running" or "stopped")
	@$(ROOT_DIR)/scripts/get_game_status.sh

check_config: .check-config  ## Check the configuration file
	@$(ROOT_DIR)/scripts/misc/check_config.sh .env

build_force: .check-config ## Build a docker image of compiled KBEngine without using of cache
	@$(ROOT_DIR)/scripts/build/build_kbe_compiled.sh \
		--kbe-git-commit=$(KBE_GIT_COMMIT) \
		--kbe-user-tag=$(KBE_USER_TAG) \
		--force

logs_kibana:  ## Show the log viewer in the web interface (Kibana)
	@$(ELK_SCRIPTS)/is_running.sh --print-error 1>/dev/null
	@python3 -c "import webbrowser; webbrowser.open('http://localhost:5601/')"

logs_dejavu:  ## Show the log viewer in the web interface (Dejavu)
	@$(ELK_SCRIPTS)/is_running.sh --print-error 1>/dev/null
	@python3 -c "import webbrowser; webbrowser.open('http://localhost:1358/')"

logs_console: .check_config  ## Show actual log records of the game in the console
	-@$(ROOT_DIR)/scripts/misc/tail_logs.sh \
		--kbe-git-commit=$(KBE_GIT_COMMIT) \
		--kbe-user-tag=$(KBE_USER_TAG) \
		--assets-version=$(KBE_ASSETS_VERSION)

define HELP_TEXT
*** [shedu] Help ***

The project builds, packages and starts kbengine and kbe environment \
in docker containers.

The .env file in the root directory is mandatory. Copy the config from the "configs" directory
or set your own settings in the "<project_dir>/.env" settings file. For more information
visit the page <https://github.com/ve-i-uj/shedu>

Example:

cp configs/kbe-v2.5.12-demo.env .env
make build
make start
make logs_console
# Or you can view the game log records in the web intarface of Kibana or Dejavu
# It needs to wait about a minute after the game ELK started because the ElasticSearch needs
# time to up. Then run this command and the web page must open in your web browser.
make logs_dejavu
_____

Rules:

endef

export HELP_TEXT
help:  ## This help
	@echo "$$HELP_TEXT"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $$(echo $(MAKEFILE_LIST) | cut -d " " -f1) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "%-15s %s\n", $$1, $$2}'
	@echo

# The strange way to set delimiter in the docs
-----:  ## -----

build_kbe: .check-config ## Build a docker image of KBEngine
	@$(SCRIPTS)/build/build_kbe_compiled.sh \
		--kbe-git-commit=$(KBE_GIT_COMMIT) \
		--kbe-user-tag=$(KBE_USER_TAG) \
		--kbe-compiled-image-tag-sha=$(KBE_COMPILED_IMAGE_TAG_SHA) \
		--kbe-compiled-image-tag-1=$(KBE_COMPILED_IMAGE_TAG_1)

build_game: .check-config  ## Build a kbengine docker image contained assets. It binds "assets" with the built kbengine image
	@$(SCRIPTS)/build/build_pre_assets.sh
	@$(SCRIPTS)/build/build_assets.sh \
		--assets-sha=$(KBE_ASSETS_SHA) \
		--assets-path=$(KBE_ASSETS_PATH) \
		--assets-version=$(KBE_ASSETS_VERSION) \
		--env-file=.env \
		--kbengine-xml-args=$(kbengine_xml_args) \
		--kbe-compiled-image-tag-sha=$(KBE_COMPILED_IMAGE_TAG_SHA)

start_game: .check-config  ## Start the docker image contained the game
	@$(SCRIPTS)/start_game.sh \
		--assets-path=$(KBE_ASSETS_PATH) \
		--assets-image=$(ASSETS_IMAGE_NAME):$(KBE_ASSETS_VERSION)

stop_game:  ## Stop the docker container contained the game
	@$(ROOT_DIR)/scripts/stop_game.sh

# The strange way to set delimiter in the docs
-----:  ## -----

build_elk:  ## Build ELK images (Elasticsearch + Logstash + Kibana)
	@export GAME_UNIQUE_NAME=$(GAME_UNIQUE_NAME); \
		! $(ELK_SCRIPTS)/is_built.sh --print-error
	@$(ELK_SCRIPTS)/build_elk.sh

start_elk: stop_elk  ## Start the game ELK (<https://www.elastic.co/what-is/elk-stack>)
	@export GAME_UNIQUE_NAME=$(GAME_UNIQUE_NAME); \
		$(ELK_SCRIPTS)/is_built.sh --print-error 1>/dev/null
	@docker-compose -f $(ROOT_DIR)/docker-compose.elk.yml up -d

stop_elk: ## Stop the game ELK
	@docker-compose -f $(ROOT_DIR)/docker-compose.elk.yml rm -fs

clean_elk: stop_elk  ## Delete the game ELK artefacts
	@$(ELK_SCRIPTS)/clean_elk.sh

restart_elk: start_elk

is_elk_running:  ## Is the game ELK running?
	@$(ELK_SCRIPTS)/is_running.sh --print-info-only

is_elk_built:  ## Are the game ELK images built?
	@export GAME_UNIQUE_NAME=$(GAME_UNIQUE_NAME); \
		$(ELK_SCRIPTS)/is_built.sh --print-info-only

restart_elk: start_elk

elk_debug_restart_logstash:
	-@docker-compose -f $(ROOT_DIR)/docker-compose.elk.yml restart kbe-log-elk-logstash

elk_debug_stop_logstash:
	-@docker-compose -f $(ROOT_DIR)/docker-compose.elk.yml stop kbe-log-elk-logstash

elk_debug_logstash:
	-@docker-compose -f $(ROOT_DIR)/docker-compose.elk.yml run \
		-i \
		--rm \
		 kbe-log-elk-logstash \
		 /bin/bash

# Public debug rules

# The strange way to set delimiter in the docs
-----:  ## -----

go_into:  ## [Debug] Go into the running game container
	@$(ROOT_DIR)/scripts/misc/go_into_container.sh

print:  ## [Debug] List built kbe images
	@echo -e "Built kbe images:"
	@$(ROOT_DIR)/scripts/misc/list_images.sh
	@echo

push_kbe: .check_config  ## [Debug] Push the image to the docker hub repository
	@$(ROOT_DIR)/scripts/build/push_kbe.sh \
		--kbe-git-commit=$(KBE_GIT_COMMIT) \
		--kbe-user-tag=$(KBE_USER_TAG)

version:  ## [Debug] Current version of the shedu
	@$(ROOT_DIR)/scripts/version/get_version.sh

# Hidden debug rules (with one # in the doc string )

go_into_kibana:  # [Debug] Go into the running Kibana container
	@docker exec --interactive --tty ${ELK_KIBANA_CONTATINER_NAME} /bin/bash

go_into_elastic:  # [Debug] Go into the running ElasticSearch container
	@docker exec --interactive --tty ${ELK_ES_CONTATINER_NAME} /bin/bash

go_into_logstash:  # [Debug] Go into the running LogStash container
	@docker exec --interactive --tty ${ELK_LOGSTASH_CONTATINER_NAME} /bin/bash

logs_elk_compose:  # [Debug] Show the ELK log records in the console
	@docker-compose -f $(ROOT_DIR)/docker-compose.elk.yml logs -f

