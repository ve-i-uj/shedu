SHELL := /bin/bash

ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

.PHONY : all help build clean start stop

.DEFAULT:
	@echo Use \"make help\"

all: help

# Это правило нужно поместить ДО импорта переменных окружения
.check-env:
ifeq ($(GAME_UNIQUE_NAME), )
	$(error The env. variable "GAME_UNIQUE_NAME" is undefined)
endif

# Импорт переменых окружения из инициализационного файла для скриптов
$(shell . $(ROOT_DIR)/../init.sh;	\
	envsubst < $(ROOT_DIR)/../init.sh \
	| grep -v '^\s*\#\|^\s*_' \
	| cut -c8- > /tmp/shedu-elk-init.sh \
)
include /tmp/shedu-elk-init.sh
export $(shell sed 's/=.*//' /tmp/shedu-elk-init.sh)

build: .check-env clean  ## Build ELK images
	@$(ROOT_DIR)/build_elk.sh

start: .check-env stop  ## Start ELK
	@docker-compose up -d

stop: .check-env ## Stop ELK
	@docker-compose rm -fsv

clean: .check-env stop  ## Delete artefacts (containers, volumes, docker networks, etc)
	@$(ROOT_DIR)/clean_elk.sh

help: .check-env ## This help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $$(echo $(MAKEFILE_LIST) | cut -d " " -f1) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "%-15s %s\n", $$1, $$2}'
	@echo

go_into_kibana:  .check-env  ## [Debug] Go into the running Kibana container
	@docker exec --interactive --tty ${ELK_KIBANA_CONTATINER_NAME} /bin/bash

go_into_elastic:   .check-env ## [Debug] Go into the running ElasticSearch container
	@docker exec --interactive --tty ${ELK_ES_CONTATINER_NAME} /bin/bash

go_into_logstash:  .check-env  ## [Debug] Go into the running LogStash container
	@docker exec --interactive --tty ${ELK_LOGSTASH_CONTATINER_NAME} /bin/bash

logs_compose:  .check-env  ## [Debug] Show log records
	@docker-compose logs -f

echo: .check-env  ## [Debug] Check import of the environment variables
	@echo ELK_KIBANA_CONTATINER_NAME=${ELK_KIBANA_CONTATINER_NAME}
	@echo TEST=${TEST}
	@echo GAME_UNIQUE_NAME=\"${GAME_UNIQUE_NAME}\"
	@echo ELK_LOGSTASH_IMAGE_TAG=\"${ELK_LOGSTASH_IMAGE_TAG}\"

logs_dejavu:  ## [Debug] Show the log viewer in the web interface (Dejavu)
	-@python3 -c "import webbrowser; webbrowser.open('http://localhost:1358/')"

logs_kibana:  ## [Debug] Show the log viewer in the web interface (Kibana)
	-@python3 -c "import webbrowser; webbrowser.open('http://localhost:5601/')"

restart: stop start

restart_logstash:
	-@docker-compose restart kbe-log-elk-logstash

stop_logstash:
	-@docker-compose stop kbe-log-elk-logstash

debug_logstash:
	-@docker-compose run \
		-i \
		 kbe-log-elk-logstash \
		 /bin/bash

full_restart: clean build start  ## [Debug] Clean, build and start
