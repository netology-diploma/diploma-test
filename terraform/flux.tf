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

resource "github_repository" "diploma-test" {
  name        = var.repository
  description = var.repository.description
  visibility  = "private"
  auto_init   = true
}

resource "flux_bootstrap_git" "diploma-test" {
  depends_on = [github_repository.diploma-test]

  embedded_manifests = true
  path               = "k8s"
}
