#!/bin/bash

set -e

loadImage(){
  t=$1
  if [[ "$(docker images -q $t 2> /dev/null)" == "" ]]; then
     (set -x; docker pull $t)
  fi
  (set -x; kind load docker-image --name otel $t)
}

loadImage quay.io/jetstack/cert-manager-controller:v1.9.1
loadImage quay.io/jetstack/cert-manager-cainjector:v1.9.1
loadImage quay.io/jetstack/cert-manager-webhook:v1.9.1
loadImage ghcr.io/fluxcd/helm-controller:v0.22.2
loadImage ghcr.io/fluxcd/source-controller:v0.26.1
loadImage jaegertracing/jaeger-operator:1.37.0
loadImage jaegertracing/all-in-one:1.37.0
loadImage ghcr.io/open-telemetry/opentelemetry-operator/opentelemetry-operator:0.58.0
loadImage gcr.io/kubebuilder/kube-rbac-proxy:v0.11.0
loadImage docker.io/kurtis/otel-collector:v1.0.3
loadImage docker.io/bitnami/kubectl:1.21
loadImage jimmidyson/configmap-reload:v0.5.0
loadImage quay.io/prometheus/prometheus:v2.36.2
loadImage promlabs/promlens:v1.1.0
loadImage traefik:2.8.0
