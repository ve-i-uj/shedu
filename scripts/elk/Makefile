SHELL := /bin/bash

ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

export $(shell sed 's/=.*//' ../init.sh)


.PHONY : all help build clean start stop

.DEFAULT:
	@echo Use \"make help\"

all: help

build: clean  ## Build ELK images
	@$(ROOT_DIR)/build_elk.sh

start:  ## Start ELK
	@$(ROOT_DIR)/start_elk.sh

stop:  ## Stop ELK
	@$(ROOT_DIR)/stop_elk.sh

clean:  ## Delete artefacts (containers, volumes, docker networks, etc)
	@$(ROOT_DIR)/clean_elk.sh

help:  ## This help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $$(echo $(MAKEFILE_LIST) | cut -d " " -f1) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "%-15s %s\n", $$1, $$2}'
	@echo
