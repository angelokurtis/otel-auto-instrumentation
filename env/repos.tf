resource "kubectl_manifest" "jetstack_helm_repository" {
  yaml_body = <<YAML
apiVersion: source.toolkit.fluxcd.io/v1beta1
kind: HelmRepository
metadata:
  name: jetstack
  namespace: ${kubernetes_namespace.fluxcd.metadata[0].name}
spec:
  interval: ${local.fluxcd.default_interval}
  url: https://charts.jetstack.io
YAML

  depends_on = [kubectl_manifest.fluxcd]
}

resource "kubectl_manifest" "jaeger_helm_repository" {
  yaml_body = <<YAML
apiVersion: source.toolkit.fluxcd.io/v1beta1
kind: HelmRepository
metadata:
  name: jaeger
  namespace: ${kubernetes_namespace.fluxcd.metadata[0].name}
spec:
  interval: ${local.fluxcd.default_interval}
  url: https://jaegertracing.github.io/helm-charts
YAML

  depends_on = [kubectl_manifest.fluxcd]
}

resource "kubectl_manifest" "traefik_helm_repository" {
  yaml_body = <<YAML
apiVersion: source.toolkit.fluxcd.io/v1beta1
kind: HelmRepository
metadata:
  name: traefik
  namespace: ${kubernetes_namespace.fluxcd.metadata[0].name}
spec:
  interval: ${local.fluxcd.default_interval}
  url: https://helm.traefik.io/traefik
YAML

  depends_on = [kubectl_manifest.fluxcd]
}

resource "kubectl_manifest" "opensearch_helm_repository" {
  yaml_body = <<YAML
apiVersion: source.toolkit.fluxcd.io/v1beta1
kind: HelmRepository
metadata:
  name: opensearch
  namespace: ${kubernetes_namespace.fluxcd.metadata[0].name}
spec:
  interval: ${local.fluxcd.default_interval}
  url: https://opensearch-project.github.io/helm-charts
YAML

  depends_on = [kubectl_manifest.fluxcd]
}

resource "kubectl_manifest" "opentelemetry_operator_git_repository" {
  yaml_body = <<YAML
apiVersion: source.toolkit.fluxcd.io/v1beta1
kind: GitRepository
metadata:
  name: opentelemetry-operator
  namespace: ${kubernetes_namespace.fluxcd.metadata[0].name}
spec:
  interval: ${local.fluxcd.default_interval}
  url: https://github.com/open-telemetry/opentelemetry-operator
  ref:
    semver: "~v${local.opentelemetry.operator.version}"
  ignore: |
    # exclude all
    /*
    # include deploy dir
    !/config
YAML

  depends_on = [kubectl_manifest.fluxcd]
}
