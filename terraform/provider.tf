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

resource "yandex_compute_instance" "k8s" {
  count       = 1
  name        = "k8s-0${count.index+1}"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 5
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.my_image.image_id
      size     = 5
    }
  }
  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.default-ru-central1-a.id
    nat       = true
  }
}