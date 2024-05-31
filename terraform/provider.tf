terraform {
  required_version = ">= 1.7.5"

  backend "remote" {
    organization = "fenixcorp"
    workspaces {
      prefix = "diploma-"
    }
  }

  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
    flux = {
      source  = "fluxcd/flux"
      version = ">= 1.2.3"
    }
  }
}

provider "yandex" {
  service_account_key_file = var.YC_SERVICE_ACCOUNT_KEY_FILE
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone_1a
}

provider "flux" {
  kubernetes = {
    host                   = yandex_kubernetes_cluster.diploma.master[0].external_v4_endpoint
    cluster_ca_certificate = yandex_kubernetes_cluster.diploma.master[0].cluster_ca_certificate
  }
  git = {
    url = "https://github.com/${var.github_org}/${var.repository}.git"
    http = {
      username = "git" # This can be any string when using a personal access token
      password = var.github_token
    }
  }
}
