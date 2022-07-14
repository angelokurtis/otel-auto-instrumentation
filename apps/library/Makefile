ifneq (,$(wildcard ./.env))
	include .env
	export $(shell sed 's/=.*//' .env)
endif

.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

.PHONY: build
build: ## Build the docker image.
	DOCKER_BUILDKIT=1 docker build -t kurtis/library:0.0.1 .

.PHONY: publish
publish: ## Push docker image with the manager.
	kind load docker-image kurtis/library:0.0.1 --name otel

.PHONY: deploy
deploy: build publish ## Deploy app to the K8s cluster specified in ~/.kube/config.
	DIGEST=$(shell docker inspect --format='{{.Id}}' kurtis/library:0.0.1); \
	cd k8s/base && kustomize edit set image library=kurtis/library@$$DIGEST
	kustomize build k8s/base | kubectl apply -f -
	kubectl rollout restart deployment library
