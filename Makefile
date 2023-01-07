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
.EXPORT_ALL_VARIABLES:
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

build: .check-config build_elk build_kbe build_game  ## Build all docker images (KBE, DB, ELK etc.)
	@log info "Done.\n"

start: .check-config start_elk start_game  ## Start the kbe game and the kbe infrastructure (DB, the KBE components, ELK etc.)
	@log info "Done.\n"

stop: .check-config stop_game  ## Stop the game (the ELK is not stopping)
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

print:  ## List the built kbe images
	@echo -e "Built kbe images:"
	@$(ROOT_DIR)/scripts/misc/list_images.sh
	@echo

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

build_game: .check-config  ## Build a kbengine docker image contained assets. It binds "assets" with the compiled kbe image
	@$(SCRIPTS)/build/build_pre_assets.sh
	@$(SCRIPTS)/build/build_assets.sh \
		--assets-sha=$(KBE_ASSETS_SHA) \
		--assets-path=$(KBE_ASSETS_PATH) \
		--assets-version=$(KBE_ASSETS_VERSION) \
		--env-file=.env \
		--kbengine-xml-args=$(kbengine_xml_args) \
		--kbe-compiled-image-tag-sha=$(KBE_COMPILED_IMAGE_TAG_SHA)

start_game: .check-config  ## Start the docker containers contained the game and the DB
	@$(SCRIPTS)/start_game.sh \
		--assets-path=$(KBE_ASSETS_PATH) \
		--assets-image=$(ASSETS_IMAGE_NAME):$(KBE_ASSETS_VERSION)

stop_game:  ## Stop the docker containers contained the game and the DB
	@$(ROOT_DIR)/scripts/stop_game.sh

# The strange way to set delimiter in the docs
-----:  ## -----

build_elk: elk_is_not_built elk_is_not_runnig  ## Build ELK images (Elasticsearch + Logstash + Kibana)
	@$(ELK_SCRIPTS)/build_elk.sh

start_elk: elk_is_not_runnig elk_is_built  ## Start the game ELK (<https://www.elastic.co/what-is/elk-stack>)
	@docker-compose -f $(ROOT_DIR)/docker-compose.elk.yml up -d --no-build

stop_elk: elk_is_runnig ## Stop the game ELK
	@docker-compose -f $(ROOT_DIR)/docker-compose.elk.yml rm -f

clean_elk: elk_is_not_runnig elk_is_built ## Delete the game ELK artefacts
	@$(ELK_SCRIPTS)/clean_elk.sh

restart_elk: stop_elk start_elk

is_elk_running:  ## Is the game ELK running?
	@$(ELK_SCRIPTS)/is_running.sh --info

is_elk_built:  ## Are the game ELK images built?
	@$(ELK_SCRIPTS)/is_built.sh --info

# The strange way to set delimiter in the docs
-----:  ## -----

go_into:  ## [Dev] Go into the running game container
	@$(ROOT_DIR)/scripts/misc/go_into_container.sh

build_force: .check-config ## [Dev] Build a docker image of compiled KBEngine without using of cache
	@$(ROOT_DIR)/scripts/build/build_kbe_compiled.sh \
		--kbe-git-commit=$(KBE_GIT_COMMIT) \
		--kbe-user-tag=$(KBE_USER_TAG) \
		--force

push_kbe: .check_config ## [Dev] Push the image to the docker hub repository
	@$(ROOT_DIR)/scripts/build/push_kbe.sh \
		--kbe-git-commit=$(KBE_GIT_COMMIT) \
		--kbe-user-tag=$(KBE_USER_TAG)

version:  ## [Dev] The current version of the shedu
	@$(ROOT_DIR)/scripts/version/get_version.sh

# Hidden debug rules (with one # in the doc string )

elk_is_built: # [Debug] Check the ELK is built. Raise error otherwise
	@source $(SCRIPTS)/log.sh; \
	if ! $(ELK_SCRIPTS)/is_built.sh; then \
		log error "The \"$(GAME_UNIQUE_NAME)\" ELK services is NOT built. Run \"make build_elk\" at first"; \
		exit 1; \
	fi

elk_is_not_built: # [Debug] Check the ELK is NOT built. Raise error otherwise
	@source $(SCRIPTS)/log.sh; \
	if $(ELK_SCRIPTS)/is_built.sh; then \
		log error "The \"$(GAME_UNIQUE_NAME)\" ELK images are already built. Run \"make clean_elk\" if you need to rebuild ELK"; \
		exit 1; \
	fi

elk_is_runnig: # [Debug] Check the ELK is running. Raise error otherwise
	@source $(SCRIPTS)/log.sh; \
	if ! $(ELK_SCRIPTS)/is_running.sh; then \
		log error  "The \"$(GAME_UNIQUE_NAME)\" ELK services are NOT running now. Run \"make start_elk\" at first"; \
		exit 1; \
	fi

elk_is_not_runnig: # [Debug] Check the ELK is NOT running. Raise error otherwise
	@source $(SCRIPTS)/log.sh; \
	if $(ELK_SCRIPTS)/is_running.sh; then \
		log error  "The \"$(GAME_UNIQUE_NAME)\" ELK services are running now. Run \"make stop_elk\" at first"; \
		exit 1; \
	fi

go_into_kibana:  # [Debug] Go into the running Kibana container
	@docker exec --interactive --tty ${ELK_KIBANA_CONTATINER_NAME} /bin/bash

go_into_elastic:  # [Debug] Go into the running ElasticSearch container
	@docker exec --interactive --tty ${ELK_ES_CONTATINER_NAME} /bin/bash

go_into_logstash:  # [Debug] Go into the running LogStash container
	@docker exec --interactive --tty ${ELK_LOGSTASH_CONTATINER_NAME} /bin/bash

logs_elk_compose:  # [Debug] Show the ELK log records in the console
	@docker-compose -f $(ROOT_DIR)/docker-compose.elk.yml logs -f

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

echo:
	@echo GAME_UNIQUE_NAME=$(GAME_UNIQUE_NAME)
	@echo KBE_GIT_COMMIT=$(KBE_GIT_COMMIT)
