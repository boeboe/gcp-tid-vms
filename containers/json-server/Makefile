# General release info
DOCKER_ACCOUNT := boeboe
APP_NAME       := json-server
APP_VERSION    := 1.0.0

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

build: ## Build container
	docker build --no-cache -t $(DOCKER_ACCOUNT)/$(APP_NAME) .

run: ## Run container
	docker run -it --rm -p 8080:8080 --name=$(APP_NAME) $(DOCKER_ACCOUNT)/$(APP_NAME)

shell: ## Login with bash in running container
	docker exec -it $(APP_NAME) /bin/bash

stop: ## Stop and remove a running container
	docker stop $(APP_NAME) || true
	docker rm $(APP_NAME) || true

publish: ## Tag and publish container
	docker tag $(DOCKER_ACCOUNT)/$(APP_NAME) $(DOCKER_ACCOUNT)/$(APP_NAME):${APP_VERSION}
	docker tag $(DOCKER_ACCOUNT)/$(APP_NAME) $(DOCKER_ACCOUNT)/$(APP_NAME):latest
	docker push $(DOCKER_ACCOUNT)/$(APP_NAME):${APP_VERSION}
	docker push $(DOCKER_ACCOUNT)/$(APP_NAME):latest

release: build publish ## Make a full release
