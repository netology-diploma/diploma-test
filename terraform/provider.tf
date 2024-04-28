terraform {
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
  }
}

provider "yandex" {
  service_account_key_file = var.YC_SERVICE_ACCOUNT_KEY_FILE
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone_1a
}
