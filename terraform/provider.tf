terraform {
  backend "remote" {
    organization = "fenixcorp"
    workspaces {
      prefix = "diploma-test"
    }
  }
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  zone                     = "ru-central1-a"
}

resource "yandex_compute_instance" "vm-1" {
  name = "test-vm-1"
}
