ifneq (,$(wildcard ./.env))
	include .env
	export $(shell sed 's/=.*//' .env)
endif

.PHONY: help
help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

.PHONY: build
build:
	docker build -t kurtis/library:0.0.1 .

.PHONY: publish
publish:
	kind load docker-image kurtis/library:0.0.1 --name otel

.PHONY: deploy
deploy: build publish
	kubectl apply -f ./k8s -n default

.PHONY: deploy
deploy: build publish
	DIGEST=$(shell docker inspect --format='{{.Id}}' kurtis/library:0.0.1); \
	cd k8s/base && kustomize edit set image library=kurtis/library:0.0.1@$$DIGEST
	kustomize build k8s/overlays/staging | kubectl apply -f -
