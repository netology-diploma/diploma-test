data "terraform_remote_state" "diploma-test" {
  backend = "remote"
  config = {
    organization = "fenixcorp"
    workspaces = {
      name = "diploma-${var.environment}"
    }
  }
}

data "yandex_client_config" "diploma-test" {}

data "kubeseal_secret" "cloudflare-api-token" {
  name = "cloudflare-api-token"
  namespace = "external-dns"
  type = "Opaque"

  secrets = {
    apiToken = var.CF_API_TOKEN
  }
  controller_name = "sealed-secrets"
  controller_namespace = "sealed-secrets"

  depends_on = [flux_bootstrap_git.diploma-test]
}
