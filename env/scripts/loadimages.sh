#!/bin/bash

set -e

loadImage(){
  t=$1
  if [[ "$(docker images -q $t 2> /dev/null)" == "" ]]; then
     (set -x; docker pull $t)
  fi
  (set -x; kind load docker-image --name otel $t)
}

loadImage docker.io/bitnami/kubectl:1.23
loadImage gcr.io/kubebuilder/kube-rbac-proxy:v0.11.0
loadImage ghcr.io/fluxcd/helm-controller:v0.25.0
loadImage ghcr.io/fluxcd/kustomize-controller:v0.29.0
loadImage ghcr.io/fluxcd/source-controller:v0.30.0
loadImage ghcr.io/open-telemetry/opentelemetry-operator/opentelemetry-operator:0.60.0
loadImage grafana/grafana:9.1.6
loadImage jaegertracing/all-in-one:1.38.0
loadImage jimmidyson/configmap-reload:v0.7.1
loadImage kurtis/bets:1.0.0-java-spring
loadImage kurtis/championships:1.0.0-java-spring
loadImage kurtis/matches:1.0.0-java-spring
loadImage kurtis/otel-collector:v1.0.8
loadImage kurtis/teams:1.0.0-java-spring
loadImage quay.io/jetstack/cert-manager-cainjector:v1.9.1
loadImage quay.io/jetstack/cert-manager-controller:v1.9.1
loadImage quay.io/jetstack/cert-manager-webhook:v1.9.1
loadImage quay.io/prometheus/node-exporter:v1.3.1
loadImage quay.io/prometheus/prometheus:v2.38.0
loadImage registry.k8s.io/kube-state-metrics/kube-state-metrics:v2.5.0
loadImage traefik:2.8.7
