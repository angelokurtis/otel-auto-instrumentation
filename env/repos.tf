locals {
  helm_repositories = {
    traefik              = { repository = "https://helm.traefik.io/traefik" }
    jetstack             = { repository = "https://charts.jetstack.io" }
    jaeger               = { repository = "https://jaegertracing.github.io/helm-charts" }
    opentelemetry        = { repository = "https://open-telemetry.github.io/opentelemetry-helm-charts" }
    prometheus-community = { repository = "https://prometheus-community.github.io/helm-charts" }
    ricardo              = { repository = "https://ricardo-ch.github.io/helm-charts" }
  }
}

resource "kubectl_manifest" "helm_repository" {
  for_each = local.helm_repositories

  server_side_apply = true
  yaml_body         = <<YAML
apiVersion: source.toolkit.fluxcd.io/v1beta1
kind: HelmRepository
metadata:
  name: ${each.key}
  namespace: ${kubernetes_namespace.fluxcd.metadata[0].name}
spec:
  interval: ${local.fluxcd.default_interval}
  timeout: ${local.fluxcd.default_timeout}
  url: ${each.value.repository}
YAML

  depends_on = [kubectl_manifest.fluxcd]
}
