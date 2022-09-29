locals {
  helm_releases = {
    cert-manager = {
      namespace       = kubernetes_namespace_v1.cert_manager.metadata[0].name,
      helm_repository = "jetstack",
      values          = local.cert_manager,
    }
    grafana = {
      namespace       = kubernetes_namespace_v1.grafana.metadata[0].name,
      helm_repository = "grafana",
      dependsOn       = [{ name = "traefik", namespace = kubernetes_namespace_v1.traefik.metadata[0].name }],
      values          = local.grafana,
    }
    jaeger = {
      namespace       = kubernetes_namespace_v1.jaeger.metadata[0].name,
      helm_repository = "jaegertracing",
      dependsOn       = [{ name = "traefik", namespace = kubernetes_namespace_v1.traefik.metadata[0].name }],
      values          = local.jaeger,
    }
    traefik = {
      namespace       = kubernetes_namespace_v1.traefik.metadata[0].name,
      chart           = "traefik",
      helm_repository = "ingress-traefik",
      values          = local.traefik,
    }
    opentelemetry-operator = {
      namespace       = kubernetes_namespace_v1.opentelemetry.metadata[0].name,
      helm_repository = "opentelemetry",
      dependsOn       = [{ name = "cert-manager", namespace = kubernetes_namespace_v1.cert_manager.metadata[0].name }],
      values          = local.opentelemetry_operator,
    }
    prometheus = {
      namespace       = kubernetes_namespace_v1.prometheus.metadata[0].name,
      helm_repository = "prometheus-community",
      dependsOn       = [{ name = "traefik", namespace = kubernetes_namespace_v1.traefik.metadata[0].name }],
      values          = local.prometheus,
    }
  }
}

resource "kubectl_manifest" "helm_release" {
  for_each = local.helm_releases

  server_side_apply = true
  yaml_body         = yamlencode({
    apiVersion = "helm.toolkit.fluxcd.io/v2beta1"
    kind       = "HelmRelease"
    metadata   = { name = each.key, namespace = each.value.namespace }
    spec       = {
      chart = {
        spec = {
          chart             = try(each.value.chart, each.key)
          reconcileStrategy = "ChartVersion"
          version           = try(each.value.version, "*")
          sourceRef         = {
            kind      = "HelmRepository"
            name      = kubectl_manifest.helm_repository[each.value.helm_repository].name
            namespace = kubectl_manifest.helm_repository[each.value.helm_repository].namespace
          }
        }
      }
      interval  = local.fluxcd.default_interval
      values    = try(each.value.values, {})
      dependsOn = try(each.value.dependsOn, [])
    }
  })

  depends_on = [kubectl_manifest.fluxcd]
}
