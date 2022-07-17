ifneq (,$(wildcard ./.env))
	include .env
	export $(shell sed 's/=.*//' .env)
endif

.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

.PHONY: release
release: ## Bump A Patch Version.
	./mvnw validate -DbumpPatch

.PHONY: build
build: ## Build the docker image.
	VERSION=$(shell ./mvnw help:evaluate -Dexpression=project.version -q -DforceStdout); \
	DOCKER_BUILDKIT=1 docker build -t kurtis/library:$$VERSION .

.PHONY: publish
publish: ## Push docker image with the manager.
	VERSION=$(shell ./mvnw help:evaluate -Dexpression=project.version -q -DforceStdout); \
	kind load docker-image kurtis/library:$$VERSION --name otel

.PHONY: deploy
deploy: build publish ## Deploy app to the K8s cluster specified in ~/.kube/config.
	VERSION=$(shell ./mvnw help:evaluate -Dexpression=project.version -q -DforceStdout); \
	cd k8s/base && kustomize edit set image library=kurtis/library:$$VERSION
	kustomize build k8s/base | kubectl apply -f -
