data "flux_install" "main" {
  version        = local.flux.version
  target_path    = "fluxcd"
  namespace      = var.fluxcd_namespace
  network_policy = false
}

data "kubectl_file_documents" "fluxcd" {
  content = data.flux_install.main.content
}

resource "kubectl_manifest" "fluxcd" {
  for_each  = data.kubectl_file_documents.fluxcd.manifests
  yaml_body = each.value

  depends_on = [kubernetes_namespace.fluxcd]
}

resource "kubernetes_namespace" "fluxcd" {
  metadata {
    name   = var.fluxcd_namespace
    labels = {
      "app.kubernetes.io/instance" = "fluxcd"
      "app.kubernetes.io/part-of"  = "flux"
      "app.kubernetes.io/version"  = local.flux.version
    }
  }
}

resource "kubectl_manifest" "source_controller_ingress" {
  yaml_body = <<YAML
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: source-controller
  namespace: ${kubernetes_namespace.fluxcd.metadata[0].name}
spec:
  ingressClassName: traefik
  rules:
    - host: ${local.flux.source_controller.host}
      http:
        paths:
          - backend:
              service:
                name: source-controller
                port:
                  number: 80
            pathType: ImplementationSpecific
YAML

  depends_on = [kubectl_manifest.fluxcd]
}