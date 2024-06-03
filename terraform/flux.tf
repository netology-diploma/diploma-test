resource "tls_private_key" "flux" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "github_repository_deploy_key" "flux" {
  title      = "Flux"
  repository = var.repository
  key        = tls_private_key.flux.public_key_openssh
  read_only  = "false"
}

resource "flux_bootstrap_git" "diploma-test" {
  depends_on = [
    github_repository_deploy_key.flux,
    yandex_kubernetes_node_group.diploma-nodes
  ]

  embedded_manifests = true
  path               = "k8s"
}
