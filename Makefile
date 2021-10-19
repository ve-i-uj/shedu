VERSION=$(shell ./scripts/version/get_version.sh)

.DEFAULT_GOAL := help

.PHONY: help

help: ## This help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

# *** Main targets ***

build_kbe: ## Build a docker image of KBEngine.
	@echo TODO

clean: ## Delete artefacts connected with the projects (containers, volumes, docker networks, etc).
	@echo TODO

build_game: ## Build a kbengine docker image contained assets. It binds "assets" with the built kbengine image.
	@echo TODO

run:  ## Run the docker image contained the game.
	@echo TODO


# *** Develop targets ***

version:
	@echo $(VERSION)
