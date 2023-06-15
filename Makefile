SHELL := /bin/bash

ROOT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
SCRIPTS := $(ROOT_DIR)/scripts

# Check the .env file exists
# Импорт переменых окружения из инициализационного файла, чтобы иметь
# возможность запускать здесь docker-compose
ifneq ("$(wildcard .env)","")
	include .env
	export $(shell sed 's/=.*//' .env)
	tmp_dir := /tmp/shedu
$(shell mkdir $(tmp_dir) 2>/dev/null; \
		source $(ROOT_DIR)/.env; \
		source $(SCRIPTS)/init.sh; \
		envsubst < $(SCRIPTS)/init.sh \
		| grep '^export' \
		| cut -c8- > $(tmp_dir)/environment.mk \
	)
	include $(tmp_dir)/environment.mk
	export $(shell sed 's/=.*//' $(tmp_dir)/environment.mk)
endif

# * Перезагрузим часть переменных + какие-то создадим для docker-compose

ifeq ($(KBE_GIT_COMMIT),)
	# Если хэш целевого комита не выставлен, то берётся последний комит из репозитория
	override KBE_GIT_COMMIT = $(shell $(SCRIPTS)/misc/get_latest_kbe_sha.sh)
endif

KBE_COMPILED_IMAGE_NAME_SHA = $(KBE_COMPILED_IMAGE_NAME):$(KBE_GIT_COMMIT)
KBE_COMPILED_IMAGE_NAME_1 = $(KBE_COMPILED_IMAGE_NAME):$(KBE_GIT_COMMIT)
ifneq ($(KBE_USER_TAG),)
	override KBE_COMPILED_IMAGE_NAME_1 = $(KBE_COMPILED_IMAGE_NAME):$(KBE_USER_TAG)-$(KBE_GIT_COMMIT)
endif

SHEDU_VERSION := $(shell $(SCRIPTS)/version/get_version.sh)
ENKI_VERSION := $(shell $(ROOT_DIR)/enki/scripts/version/get_version.sh)
override PRE_ASSETS_IMAGE_NAME := $(PRE_ASSETS_IMAGE_NAME):$(SHEDU_VERSION)
override KBE_ENKI_PYTHON_IMAGE_NAME := $(KBE_ENKI_PYTHON_IMAGE_NAME):$(ENKI_VERSION)
override KBE_ASSETS_IMAGE_NAME := $(KBE_ASSETS_IMAGE_NAME):$(KBE_ASSETS_VERSION)

ifeq ($(KBE_ASSETS_PATH), demo)
	override KBE_ASSETS_PATH := /tmp/shedu/kbe-demo-assets-$(shell date +"%Y-%m-%d")
    $(shell if [ ! -d $(KBE_ASSETS_PATH) ]; then \
		git clone "$(KBE_ASSETS_DEMO_GIT_URL)" $(KBE_ASSETS_PATH); \
	fi)
endif

.PHONY: *
.EXPORT_ALL_VARIABLES:
.DEFAULT:
	@echo Use \"make help\"

all: help

status: config_is_ok ## Return the game status ("running" or "stopped")
	@$(SCRIPTS)/misc/get_status.sh

force_stop_game: ## Force stop any game
	@res=$$(docker ps --filter name=$(KBE_COMPONENT_CONTAINER_NAME) -q); \
	if [ ! -z "$$res" ]; then \
		docker stop "$$res"; \
	fi
	@res=$$(docker container ls --all --filter name=$(KBE_COMPONENT_CONTAINER_NAME) -q); \
	if [ ! -z "$$res" ]; then \
		echo $$res | xargs docker container rm --volume; \
	fi

clean_all: config_is_ok game_is_not_running elk_is_not_runnig ## Delete the artefacts of all games (not only the current project)
	@res=$$(docker network ls --filter "name=*kbe-net*" -q); \
	if [ ! -z "$$res" ]; then \
		docker network rm $$res; \
	fi
	@res=$$(docker volume ls --filter name="*kbe*-data" -q); \
	if [ ! -z "$$res" ]; then \
		docker volume rm $$res; \
	fi
	@res=$$(docker images ls --filter reference="$(PROJECT_NAME)/*" --format "{{.Repository}}:{{.Tag}}"); \
	if [ ! -z "$$res" ]; then \
		echo $$res | xargs docker rmi; \
	fi
	@rm -rf $(PROJECT_CACHE_DIR)

check_config: ## Check the configuration file
	@$(SCRIPTS)/misc/print_configs_vars.sh --only-user-settings
	@$(SCRIPTS)/misc/check_config.sh $(ROOT_DIR)/.env

# При остановке ELK не сохраняется view Kibana в ES. Поэтому импортируем view
# и сразу его открываем с нужными полями в таблице
logs_kibana: elk_is_runnig ## Show the log viewer in the web interface (Kibana)
	@curl -X POST \
		http://localhost:5601/api/saved_objects/_import?overwrite=true \
		-H "kbn-xsrf: true" --form file=@$(ROOT_DIR)/data/kibana/export.ndjson \
		-s -o /dev/null
	@url="http://localhost:5601/app/discover#/view/9bdada80-a22e-11ed-ac3b-47395a81c705"; \
		python3 -c "import webbrowser; webbrowser.open(\"$$url\")"

logs_dejavu: elk_is_runnig ## Show the log viewer in the web interface (Dejavu)
	@python3 -c "import webbrowser; webbrowser.open('http://localhost:1358/')"

logs_console: config_is_ok ## Show actual log records of the game in the console
	@docker exec \
		-it $(KBE_COMPONENT_CONTAINER_NAME)-logger \
		/bin/bash .shedu/scripts/deploy/tail_logs.sh

-----: ## -----

build_kbe: config_is_ok ## Build a docker image of KBEngine
	@$(SCRIPTS)/build_kbe_compiled.sh \
		--kbe-git-commit=$(KBE_GIT_COMMIT) \
		--kbe-compiled-image-name-sha=$(KBE_COMPILED_IMAGE_NAME_SHA) \
		--kbe-compiled-image-name-1=$(KBE_COMPILED_IMAGE_NAME_1)

clean_kbe: config_is_ok kbe_is_built game_is_not_running # Clean the compiled kbe image
	@if [ "$(KBE_COMPILED_IMAGE_NAME_SHA)" != "$(KBE_COMPILED_IMAGE_NAME_1)" ]; then \
		docker rmi $(KBE_COMPILED_IMAGE_NAME_1); \
	fi
	@docker rmi $(KBE_COMPILED_IMAGE_NAME_SHA)

-----: ## -----

build_game: config_is_ok game_is_not_built kbe_is_built ## Build a kbengine docker image contained assets. It binds "assets" with the compiled kbe image
	@docker pull $(KBE_DB_IMAGE_NAME)
	@docker tag $(KBE_DB_IMAGE_NAME) $(KBE_DB_IMAGE_TAGGED_NAME)
	@$(SCRIPTS)/dev/update_enki.sh
	@docker build \
		--file "$(DOCKERFILE_ENKI_PYTHON)" \
		--build-arg KBE_CONTAINER_USER="$(KBE_CONTAINER_USER)" \
		--build-arg GAME_NAME="$(GAME_NAME)" \
		--tag "$(KBE_ENKI_PYTHON_IMAGE_NAME)" \
		.
	@docker build \
		--file "$(DOCKERFILE_PRE_ASSETS)" \
		--build-arg KBE_COMPILED_IMAGE_NAME="$(KBE_COMPILED_IMAGE_NAME_SHA)" \
		--build-arg KBE_ENKI_PYTHON_IMAGE_NAME="$(KBE_ENKI_PYTHON_IMAGE_NAME)" \
		--tag "$(PRE_ASSETS_IMAGE_NAME)" \
		.
	@cd $(KBE_ASSETS_PATH); \
	docker build \
		--file "$(DOCKERFILE_KBE_ASSETS)" \
		--build-arg PRE_ASSETS_IMAGE_NAME="$(PRE_ASSETS_IMAGE_NAME)" \
		--build-arg KBE_ASSETS_SHA="$(KBE_ASSETS_SHA)" \
		--build-arg KBE_KBENGINE_XML_ARGS="$(KBE_KBENGINE_XML_ARGS)" \
		--build-arg GAME_NAME="$(GAME_NAME)" \
		--build-arg KBE_CONTAINER_USER="$(KBE_CONTAINER_USER)" \
		--tag "$(KBE_ASSETS_IMAGE_NAME)" \
		.
	@docker volume create $(KBE_DB_VOLUME_NAME)
	@if [ -z "$$(docker volume ls --filter "name=$(KBE_LOG_VOLUME_NAME)" -q)" ]; then \
		docker volume create $(KBE_LOG_VOLUME_NAME); \
	fi


start_game: config_is_ok game_is_not_running game_is_built ## Start the docker containers contained the game and the DB
	@docker-compose \
		--log-level ERROR \
		-f $(ROOT_DIR)/docker-compose.yml \
		-p $(GAME_COMPOSE_PROJECT_NAME) \
		up -d

stop_game: config_is_ok game_is_running ## Stop the docker containers contained the game and the DB
	@docker-compose \
		--log-level ERROR \
		-f $(ROOT_DIR)/docker-compose.yml \
		-p $(GAME_COMPOSE_PROJECT_NAME) \
		stop
	@docker-compose \
		--log-level ERROR \
		-f $(ROOT_DIR)/docker-compose.yml \
		-p $(GAME_COMPOSE_PROJECT_NAME) \
		rm -f

clean_game: config_is_ok game_is_not_running ## Delete the artefacts connected with the project (containers, volumes, docker networks, etc)
	@docker-compose \
		--log-level ERROR \
		-f $(ROOT_DIR)/docker-compose.yml \
		-p $(GAME_COMPOSE_PROJECT_NAME) \
		down --rmi all
	@docker volume rm $(KBE_DB_VOLUME_NAME)
	@if [ -z "$$(docker volume ls --filter "name=$(ELK_ES_VOLUME_NAME)" -q)" ]; then \
		if [ ! -z "$$(docker volume ls --filter "name=$(KBE_LOG_VOLUME_NAME)" -q)" ]; then \
			docker volume rm $(KBE_LOG_VOLUME_NAME); \
		fi; \
	fi



-----: ## -----

build_elk: elk_is_not_built elk_is_not_runnig ## Build ELK images (Elasticsearch + Logstash + Kibana)
	@docker pull $(ELK_ES_IMAGE_NAME)
	@docker tag $(ELK_ES_IMAGE_NAME) $(ELK_ES_IMAGE_TAG)
	@docker pull $(ELK_KIBANA_IMAGA_NAME)
	@docker tag $(ELK_KIBANA_IMAGA_NAME) $(ELK_KIBANA_IMAGE_TAG)
	@docker pull $(ELK_LOGSTASH_IMAGA_NAME)
	@docker tag $(ELK_LOGSTASH_IMAGA_NAME) $(ELK_LOGSTASH_IMAGE_TAG)
	@docker pull $(ELK_DEJAVU_IMAGA_NAME)
	@docker tag $(ELK_DEJAVU_IMAGA_NAME) $(ELK_DEJAVU_IMAGE_TAG)
	@docker volume create $(ELK_ES_VOLUME_NAME)
	@if [ -z "$$(docker volume ls --filter "name=$(KBE_LOG_VOLUME_NAME)" -q)" ]; then \
		docker volume create $(KBE_LOG_VOLUME_NAME); \
	fi

start_elk: elk_is_not_runnig elk_is_built ## Start the game ELK (<https://www.elastic.co/what-is/elk-stack>)
	@docker-compose \
		-f $(ROOT_DIR)/docker-compose.elk.yml \
		-p $(ELK_COMPOSE_PROJECT_NAME) \
		up -d --no-build

stop_elk: elk_is_runnig ## Stop the game ELK
	@docker-compose \
		-f $(ROOT_DIR)/docker-compose.elk.yml \
		-p $(ELK_COMPOSE_PROJECT_NAME) \
		stop
	@docker-compose \
		-f $(ROOT_DIR)/docker-compose.elk.yml \
		-p $(ELK_COMPOSE_PROJECT_NAME) \
		rm -f

clean_elk: elk_is_not_runnig elk_is_built
	@docker-compose \
		--log-level ERROR \
		-f $(ROOT_DIR)/docker-compose.elk.yml \
		-p $(ELK_COMPOSE_PROJECT_NAME) \
		down --rmi all
	@docker volume rm $(ELK_ES_VOLUME_NAME)
	@if [ -z "$$(docker volume ls --filter "name=$(KBE_DB_VOLUME_NAME)" -q)" ]; then \
		if [ ! -z "$$(docker volume ls --filter "name=$(KBE_LOG_VOLUME_NAME)" -q)" ]; then \
			docker volume rm $(KBE_LOG_VOLUME_NAME); \
		fi; \
	fi

restart_elk: stop_elk start_elk

-----: ## -----

# go_into: config_is_ok game_is_running ## [Dev] Go into the running game container
go_into: config_is_ok ## [Dev] Go into the running game container
	@docker exec --interactive --tty "$(KBE_COMPONENT_CONTAINER_NAME)-machine" /bin/bash

build_force: ## [Dev] Build a docker image of compiled KBEngine without using of cache
	@$(SCRIPTS)/build_kbe_compiled.sh \
		--kbe-git-commit=$(KBE_GIT_COMMIT) \
		--kbe-user-tag=$(KBE_USER_TAG) \
		--force

push_kbe: config_is_ok kbe_is_built ## [Dev] Push the image to the docker hub repository
	@docker push $(KBE_COMPILED_IMAGE_NAME_SHA)
	@docker push $(KBE_COMPILED_IMAGE_NAME_1)

tail_elk_logs: config_is_ok elk_is_runnig ## [Dev] Show the ELK log records in the console
	@docker-compose -f $(ROOT_DIR)/docker-compose.elk.yml logs -f

version: ## [Dev] The current version of the shedu
	@$(ROOT_DIR)/scripts/version/get_version.sh

-----: ## -----

cocos_build: ## [Dev] Build the Cocos2D client demo
	@docker build \
		--file "$(DOCKERFILE_COCOS_DEMO_CLIENT)" \
		--build-arg KBE_PUBLIC_HOST="$(KBE_PUBLIC_HOST)" \
		--tag "$(KBE_DEMO_COCOS_CLIENT_IMAGE_NAME)" \
		.

cocos_start: ## [Dev] Start the Cocos2D client demo
	@python3 -c "import webbrowser; webbrowser.open('http://0.0.0.0:8080/')"
	@docker run --rm \
		-p 8080:80 \
		--name $(KBE_DEMO_COCOS_CLIENT_CONTAINER_NAME) \
		$(KBE_DEMO_COCOS_CLIENT_IMAGE_NAME)

cocos_clean: ## [Dev] Delete the image of the Cocos2D client demo
	@docker rmi $(KBE_DEMO_COCOS_CLIENT_IMAGE_NAME)

-----: ## -----

start_db_only: ## [Dev] Start DB only for debug purpose
	@docker-compose \
		--log-level ERROR \
		-f $(ROOT_DIR)/docker-compose.yml \
		-p $(GAME_COMPOSE_PROJECT_NAME) \
		up -d mariadb

stop_db_only: ## [Dev] Stop DB only for debug purpose
	@docker-compose \
		--log-level ERROR \
		-f $(ROOT_DIR)/docker-compose.yml \
		-p $(GAME_COMPOSE_PROJECT_NAME) \
		stop mariadb
	@docker-compose \
		--log-level ERROR \
		-f $(ROOT_DIR)/docker-compose.yml \
		-p $(GAME_COMPOSE_PROJECT_NAME) \
		rm -f mariadb

-----: ## -----

define HELP_TEXT
*** [shedu] Help ***

The project builds, packages and starts kbengine and kbe environment \
in docker containers.

The .env file in the root directory is mandatory. Copy the config from the "configs" directory
or set your own settings in the "<project_dir>/.env" settings file. For more information
visit the page <https://github.com/ve-i-uj/shedu>

Example:

cp configs/kbe-v2.5.12-demo.env .env
make build_game
make start_game
make logs_console
# Or you can view the game log records in the web intarface of Kibana or Dejavu
# It needs to wait about a minute after the game ELK started because the ElasticSearch needs
# time to up. Then run this command and the web page must open in your web browser.
make logs_kibana
_____

Rules:

endef

export HELP_TEXT
help: ## This help
	@echo "$$HELP_TEXT"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $$(echo $(MAKEFILE_LIST) | cut -d " " -f1) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "%-15s %s\n", $$1, $$2}'
	@echo

# Hidden for docs rules (with one # in the doc string )

game_is_built: # Check the game image exists. Raise error otherwise
	@source $(SCRIPTS)/log.sh; \
	if [ -z "$$(docker images --filter "reference=$(KBE_ASSETS_IMAGE_NAME)" -q)" ]; then \
		log error "The game image is NOT built. Run \"make build_game\" af first"; \
		exit 1; \
	fi

game_is_not_built: # Check the game image doesn't exist. Raise error otherwise
	@source $(SCRIPTS)/log.sh; \
	if [ ! -z "$$(docker images --filter "reference=$(KBE_ASSETS_IMAGE_NAME)" -q)" ]; then \
		log error "The game image is built"; \
		exit 1; \
	fi

game_is_running: # Check the game is running. Raise error otherwise
	@source $(SCRIPTS)/log.sh; \
	if [ -z "$$(docker ps --filter "name=$(KBE_COMPONENT_CONTAINER_NAME)" -q)" ]; then \
		log error "The game is NOT running. Run \"make start_game\""; \
		exit 1; \
	fi

game_is_not_running: # Check the game is not running. Raise error otherwise
	@source $(SCRIPTS)/log.sh; \
	if [ ! -z "$$(docker ps --filter "name=$(KBE_COMPONENT_CONTAINER_NAME)" -q)" ]; then \
		log error "The game is running"; \
		exit 1; \
	fi

kbe_is_built: # Check the compiled kbe image exists. Raise error otherwise
	@source $(SCRIPTS)/log.sh; \
	if [ -z "$$(docker images --filter "reference=$(KBE_COMPILED_IMAGE_NAME)" -q)" ]; then \
		log error "The \"$(KBE_COMPILED_IMAGE_NAME_1)\" image is NOT built. Run \"make build_kbe\" af first"; \
		exit 1; \
	fi

kbe_is_not_built: # Check the compiled kbe image doesn't exist. Raise error otherwise
	@source $(SCRIPTS)/log.sh; \
	if [ ! -z "$$(docker images --filter "reference=$(KBE_COMPILED_IMAGE_NAME)" -q)" ]; then \
		log error "The \"$(KBE_COMPILED_IMAGE_NAME_1)\" image is built. Run \"make clean_kbe\" at first"; \
		exit 1; \
	fi

config_is_ok: # Check the .env config is ok. Raise error otherwise
	@source $(SCRIPTS)/log.sh; \
	if ! $(ROOT_DIR)/scripts/misc/check_config.sh $(ROOT_DIR)/.env &>/dev/null; then \
		log error "The config file is malformed or doesn't exist. Run \"make check_config\""; \
		exit 1; \
	fi

elk_is_built: # Check the ELK is built. Raise error otherwise
	@source $(SCRIPTS)/log.sh; \
	images="$(ELK_ES_IMAGE_TAG) $(ELK_KIBANA_IMAGE_TAG) $(ELK_LOGSTASH_IMAGE_TAG) $(ELK_DEJAVU_IMAGE_TAG) "; \
	is_built=true; \
    for image in $$images ; do \
		if [ -z "$$( docker images --filter reference="$$image" -q )" ]; then \
			log debug "There is no image \"$$image\""; \
			is_built=false; \
		fi \
    done; \
	if $$is_built; then \
		exit 0; \
	else \
		log error "The ELK services is NOT built. Run \"make build_elk\" at first"; \
		exit 1; \
	fi

elk_is_not_built: # Check the ELK is NOT built. Raise error otherwise
	@source $(SCRIPTS)/log.sh; \
	images="$(ELK_ES_IMAGE_TAG) $(ELK_KIBANA_IMAGE_TAG) $(ELK_LOGSTASH_IMAGE_TAG) $(ELK_DEJAVU_IMAGE_TAG) "; \
	is_built=true; \
    for image in $$images ; do \
		if [ -z "$$( docker images --filter reference="$$image" -q )" ]; then \
			is_built=false; \
		fi \
    done; \
	if $$is_built; then \
		log error "The ELK images are already built. Run \"make clean\" if you need to rebuild ELK"; \
		exit 1; \
	fi

elk_is_runnig: # Check the ELK is running. Raise error otherwise
	@source $(SCRIPTS)/log.sh; \
	if [ -z "$$(docker-compose -f $(ROOT_DIR)/docker-compose.elk.yml -p $(ELK_COMPOSE_PROJECT_NAME) ps -q)" ]; then \
		log error  "The ELK services are NOT running now. Run \"make start_elk\" at first"; \
		exit 1; \
	fi

elk_is_not_runnig: # Check the ELK is NOT running. Raise error otherwise
	@source $(SCRIPTS)/log.sh; \
	if [ ! -z "$$(docker-compose -f $(ROOT_DIR)/docker-compose.elk.yml -p $(ELK_COMPOSE_PROJECT_NAME) ps -q)" ]; then \
		log error  "The ELK services are running now. Run \"make stop_elk\" at first"; \
		exit 1; \
	fi

include contrib/debug.mk

hello:
	@echo "Hello! (ROOT_DIR=$(ROOT_DIR))"
	@echo
	@echo "KBE_ASSETS_CONTAINER_NAME=$(KBE_ASSETS_CONTAINER_NAME)"
	@echo "KBE_COMPONENT_CONTAINER_NAME=$(KBE_COMPONENT_CONTAINER_NAME)"
	@echo "GAME_IDLE_START=$(GAME_IDLE_START)"
	@echo
	@echo "KBE_DB_VOLUME_NAME=$(KBE_DB_VOLUME_NAME)"

test:
	@docker version
	@docker-compose version
	@$(ROOT_DIR)/tests/run_tests.sh
