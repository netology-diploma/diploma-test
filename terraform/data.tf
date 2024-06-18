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
