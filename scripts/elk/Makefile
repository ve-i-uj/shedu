SHELL := /bin/bash

ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

export $(shell sed 's/=.*//' ../init.sh)


.PHONY : all help build clean start stop

.DEFAULT:
	@echo Use \"make help\"

all: help

build: clean  ## Build ELK images
	@$(ROOT_DIR)/build_elk.sh

start: stop  ## Start ELK
	@$(ROOT_DIR)/start_elk.sh

stop:  ## Stop ELK
	@$(ROOT_DIR)/stop_elk.sh

clean: stop  ## Delete artefacts (containers, volumes, docker networks, etc)
	@$(ROOT_DIR)/clean_elk.sh

help:  ## This help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $$(echo $(MAKEFILE_LIST) | cut -d " " -f1) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "%-15s %s\n", $$1, $$2}'
	@echo

# TODO: переменные не удаётся получить из файла (и не получится скорей всего.
# Проверять можно по правилу echo
# go_into_kibana:  ## [Debug] Go into the running Kibana container
# 	@docker exec --interactive --tty ${ELK_KIBANA_CONTATINER_NAME} /bin/bash

# go_into_elastic:  ## [Debug] Go into the running ElasticSearch container
# 	@docker exec --interactive --tty ${ELK_ES_CONTATINER_NAME} /bin/bash

logs:  ## [Debug] Show log records
	@$(ROOT_DIR)/log_elk.sh


echo:
	@echo ${ELK_KIBANA_CONTATINER_NAME}
