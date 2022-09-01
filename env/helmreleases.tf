locals {
  helm_releases = {
    traefik                = local.traefik
    opentelemetry-operator = local.opentelemetry_operator
    jaeger                 = local.jaeger
    cert-manager           = local.cert_manager
    prometheus             = local.prometheus
    promlens               = local.promlens
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
        spec = try(
          {
            chart             = try(each.value.chart, each.key)
            reconcileStrategy = "ChartVersion"
            version           = try(each.value.version, "*")
            sourceRef         = {
              kind      = "HelmRepository"
              name      = kubectl_manifest.helm_repository[each.value.helm_repository].name
              namespace = kubectl_manifest.helm_repository[each.value.helm_repository].namespace
            }
          },
          {
            chart             = try(each.value.chart, each.key)
            reconcileStrategy = "Revision"
            sourceRef         = {
              kind      = "GitRepository"
              name      = kubectl_manifest.git_repository[each.value.git_repository].name
              namespace = kubectl_manifest.git_repository[each.value.git_repository].namespace
            }
          }
        )
      }
      interval  = local.fluxcd.default_interval
      values    = try(each.value.values, {})
      dependsOn = try(each.value.dependsOn, [])
    }
  })

  depends_on = [kubectl_manifest.fluxcd]
}
