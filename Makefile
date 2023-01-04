SHELL := /bin/bash

ROOT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
SCRIPTS := $(ROOT_DIR)/scripts
ELK_SCRIPTS := $(SCRIPTS)/elk

# Check the .env file exists
ifneq ("$(wildcard .env)","")
	include .env
	export $(shell sed 's/=.*//' .env)
endif

# Импорт переменых окружения из инициализационного файла
$(shell . $(SCRIPTS)/init.sh;	\
	export GAME_UNIQUE_NAME=$(GAME_UNIQUE_NAME); \
	envsubst < $(SCRIPTS)/init.sh \
	| grep -v '^\s*\#\|^\s*_' \
	| cut -c8- > /tmp/shedu-elk-init.sh \
)
include /tmp/shedu-elk-init.sh
export $(shell sed 's/=.*//' /tmp/shedu-elk-init.sh)

# Если хэш целевого комита не выставлен, то берётся последний комит из репозитория
KBE_GIT_COMMIT := $(KBE_GIT_COMMIT)
ifeq ($(KBE_GIT_COMMIT),)
	override KBE_GIT_COMMIT := $(shell scripts/misc/get_latest_kbe_sha.sh)
		ifeq ($(KBE_GIT_COMMIT),)
			override KBE_GIT_COMMIT := 7d379b9f
		endif
endif

.PHONY: *

.DEFAULT:
	@echo Use \"make help\"

all: help

.check-config-exists:
ifeq (,$(wildcard .env))
	$(error [ERROR] No config file "$(ROOT_DIR)/.env". Use "make help")
endif

.check-game-unique-name:
ifeq ($(GAME_UNIQUE_NAME),)
	$(error The env. variable "GAME_UNIQUE_NAME" is undefined)
endif

build: build_kbe build_game  ## Build all
	@echo -e "\nDone.\n"

build_kbe: .check-config-exists ## Build a docker image of KBEngine
	@$(SCRIPTS)/build/build_kbe_compiled.sh \
		--kbe-git-commit=$(KBE_GIT_COMMIT) \
		--kbe-user-tag=$(KBE_USER_TAG)

build_game: .check-config-exists  ## Build a kbengine docker image contained assets. It binds "assets" with the built kbengine image
	@$(SCRIPTS)/build/build_pre_assets.sh
	@$(SCRIPTS)/build/build_assets.sh \
		--kbe-git-commit=$(KBE_GIT_COMMIT) \
		--kbe-user-tag=$(KBE_USER_TAG) \
		--kbe-assets-sha=$(KBE_ASSETS_SHA) \
		--assets-path=$(KBE_ASSETS_PATH) \
		--assets-version=$(KBE_ASSETS_VERSION) \
		--env-file=.env \
		--kbengine-xml-args=$(kbengine_xml_args)

start: .check-config-exists  ## Run the docker image contained the game
	@$(SCRIPTS)/start_game.sh \
		--kbe-git-commit=$(KBE_GIT_COMMIT) \
		--kbe-user-tag=$(KBE_USER_TAG) \
		--assets-path=$(KBE_ASSETS_PATH) \
		--assets-version=$(KBE_ASSETS_VERSION)

stop:  ## Stop the docker container contained the game
	@$(ROOT_DIR)/scripts/stop_game.sh > /dev/null

status:  ## Return the game status ("running" or "stopped")
	@$(ROOT_DIR)/scripts/get_game_status.sh

clean: .check-config-exists  ## Delete artefacts connected with the projects (containers, volumes, docker networks, etc)
	@$(ROOT_DIR)/scripts/clean.sh \
		--kbe-git-commit=$(KBE_GIT_COMMIT) \
		--kbe-user-tag=$(KBE_USER_TAG) \
		--assets-path=$(KBE_ASSETS_PATH) \
		--assets-version=$(KBE_ASSETS_VERSION) \

build_force: .check-config-exists ## Build a docker image of compiled KBEngine without using of cache
	@$(ROOT_DIR)/scripts/build/build_kbe_compiled.sh \
		--kbe-git-commit=$(KBE_GIT_COMMIT) \
		--kbe-user-tag=$(KBE_USER_TAG) \
		--force

define HELP_TEXT
*** [$(ROOT_DIR)] Help ***

The ROOT_DIR builds, packages and starts kbengine and kbe environment \
in the docker.

Some rules required a config file. Copy config from the "configs" directory \
or set your own settings in the "<project_dir>/.env" settings file.
The build of the ROOT_DIR will be aborted if no .env file in the ROOT_DIR \
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
	@$(ROOT_DIR)/scripts/misc/go_into_container.sh

check_config: .check-config-exists  ## [Debug] Check configuration file
	@$(ROOT_DIR)/scripts/misc/check_config.sh .env

version:  ## [Debug] Current version of the ROOT_DIR
	@$(ROOT_DIR)/scripts/version/get_version.sh

print:  ## [Debug] List built kbe images
	@echo -e "Built kbe images:"
	@$(ROOT_DIR)/scripts/misc/list_images.sh
	@echo

logs_console: .check_config  ## [Debug] Show actual log records of the game in the console
	-@$(ROOT_DIR)/scripts/misc/tail_logs.sh \
		--kbe-git-commit=$(KBE_GIT_COMMIT) \
		--kbe-user-tag=$(KBE_USER_TAG) \
		--assets-version=$(KBE_ASSETS_VERSION)

restart: stop start  ## [Debug] Stop and start

push: .check_config  ## [Debug] Push the image to the docker hub repository
	@$(ROOT_DIR)/scripts/build/push_kbe.sh \
		--kbe-git-commit=$(KBE_GIT_COMMIT) \
		--kbe-user-tag=$(KBE_USER_TAG)

# *** ElasticSearch + LogStash + Kibana (+ Dejavu) ***

elk_build: elk_clean  ## Build ELK images
	@$(ELK_SCRIPTS)/build_elk.sh

elk_start: elk_stop  ## Start ELK
	@export GAME_UNIQUE_NAME=$(GAME_UNIQUE_NAME); $(ELK_SCRIPTS)/is_built.sh --print-error 1>/dev/null
	@docker-compose -f $(ROOT_DIR)/docker-compose.elk.yml up -d

elk_stop: ## Stop ELK
	@docker-compose -f $(ROOT_DIR)/docker-compose.elk.yml rm -fs

elk_clean: elk_stop  ## Delete artefacts (containers, volumes, docker networks, etc)
	@$(ELK_SCRIPTS)/clean_elk.sh

elk_is_running:  ## Is the ELK running?
	@$(ELK_SCRIPTS)/is_running.sh

elk_is_built:  ## Are the ELK images built?
	@export GAME_UNIQUE_NAME=$(GAME_UNIQUE_NAME); $(ELK_SCRIPTS)/is_built.sh

elk_go_into_kibana:   ## [Debug] Go into the running Kibana container
	@docker exec --interactive --tty ${ELK_KIBANA_CONTATINER_NAME} /bin/bash

elk_go_into_elastic:   ## [Debug] Go into the running ElasticSearch container
	@docker exec --interactive --tty ${ELK_ES_CONTATINER_NAME} /bin/bash

elk_go_into_logstash:   ## [Debug] Go into the running LogStash container
	@docker exec --interactive --tty ${ELK_LOGSTASH_CONTATINER_NAME} /bin/bash

elk_logs_compose:   ## [Debug] Show log records
	@docker-compose -f $(ROOT_DIR)/docker-compose.elk.yml logs -f

elk_logs_dejavu:  ## [Debug] Show the log viewer in the web interface (Dejavu)
	@$(ELK_SCRIPTS)/is_running.sh --print-error 1>/dev/null
	@python3 -c "import webbrowser; webbrowser.open('http://localhost:1358/')"

elk_logs_kibana:  ## [Debug] Show the log viewer in the web interface (Kibana)
	@$(ELK_SCRIPTS)/is_running.sh --print-error 1>/dev/null
	@python3 -c "import webbrowser; webbrowser.open('http://localhost:5601/')"

elk_restart: elk_stop elk_start

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

echo: .check-config-exists .check-game-unique-name  ## [Debug] Check import of the environment variables
	@echo SCRIPTS=\"${SCRIPTS}\"
	@echo GAME_UNIQUE_NAME=\"${GAME_UNIQUE_NAME}\"
	@echo KBE_ASSETS_IMAGE=\"${KBE_ASSETS_IMAGE}\"
	@echo KBE_GIT_COMMIT=\"${KBE_GIT_COMMIT}\"
	@echo ELK_ES_IMAGE_NAME=${ELK_ES_IMAGE_NAME}
	@echo ELK_ES_IMAGE_TAG=${ELK_ES_IMAGE_TAG}
	@echo ELK_DEJAVU_IMAGA_NAME=${ELK_DEJAVU_IMAGA_NAME}
