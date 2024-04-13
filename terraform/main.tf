resource "yandex_kubernetes_cluster" "diploma" {
  network_id = yandex_vpc_network.default.id
  master {
    master_location {
      zone      = yandex_vpc_subnet.default-ru-central1-a.zone
      subnet_id = yandex_vpc_subnet.default-ru-central1-a.id
   }
  }
  service_account_id      = yandex_iam_service_account.cluster-test.id
  node_service_account_id = yandex_iam_service_account.cluster-test.id
    depends_on = [
      yandex_resourcemanager_folder_iam_member.editor,
      yandex_resourcemanager_folder_iam_member.images-puller
    ]
}

resource "yandex_vpc_network" "default" {
  name = "default"
}

resource "yandex_vpc_subnet" "default-ru-central1-a" {
  v4_cidr_blocks = ["10.128.0.0/24"]
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.default.id}"
}

resource "yandex_iam_service_account" "cluster-test" {
 name        = cluster-test
 description = "Main cluster SA"
}

resource "yandex_resourcemanager_folder_iam_member" "editor" {
 # Сервисному аккаунту назначается роль "editor".
 folder_id = "test"
 role      = "editor"
 member    = "serviceAccount:${yandex_iam_service_account.cluster-test.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "images-puller" {
 # Сервисному аккаунту назначается роль "container-registry.images.puller".
 folder_id = "test"
 role      = "container-registry.images.puller"
 member    = "serviceAccount:${yandex_iam_service_account.cluster-test.id}"
}
