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

resource "yandex_vpc_network" "default" {
  name = "default"
}

resource "yandex_vpc_subnet" "default-ru-central1-a" {
  v4_cidr_blocks = ["10.128.0.0/24"]
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.default.id}"
}
