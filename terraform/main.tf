resource "yandex_kubernetes_cluster" "diploma" {
  network_id = yandex_vpc_network.default.id
  master {
    public_ip = true
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

resource "yandex_kubernetes_node_group" "diploma-nodes" {
  cluster_id = yandex_kubernetes_cluster.diploma.id
  name       = "diploma"
  instance_template {
    name       = "test-{instance.short_id}"
    platform_id = "standard-v1"
    network_acceleration_type = "standard"
    container_runtime {
      type = "containerd"
    }
  }
  scale_policy {
    auto_scale {
      initial = 1
      max     = 3
      min     = 1
    }
  }
}

resource "yandex_vpc_network" "default" {
  name = "default"
}

resource "yandex_vpc_subnet" "default-ru-central1-a" {
  v4_cidr_blocks = ["10.128.0.0/24"]
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.default.id
}

resource "yandex_iam_service_account" "cluster-test" {
 name        = "cluster-test"
 description = "Main cluster SA"
}

resource "yandex_resourcemanager_folder_iam_member" "editor" {
 # Сервисному аккаунту назначается роль "editor".
 folder_id = var.folder_id
 role      = "editor"
 member    = "serviceAccount:${yandex_iam_service_account.cluster-test.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "images-puller" {
 # Сервисному аккаунту назначается роль "container-registry.images.puller".
 folder_id = var.folder_id
 role      = "container-registry.images.puller"
 member    = "serviceAccount:${yandex_iam_service_account.cluster-test.id}"
}

resource "yandex_vpc_security_group" "k8s-public-services" {
  name        = "k8s-public-services"
  description = "Правила группы разрешают подключение к сервисам из интернета. Примените правила только для групп узлов."
  network_id  = yandex_vpc_network.default.id
  ingress {
    protocol          = "TCP"
    description       = "Правило разрешает проверки доступности с диапазона адресов балансировщика нагрузки. Нужно для работы отказоустойчивого кластера Managed Service for Kubernetes и сервисов балансировщика."
    predefined_target = "loadbalancer_healthchecks"
    from_port         = 0
    to_port           = 65535
  }
  ingress {
    protocol          = "ANY"
    description       = "Правило разрешает взаимодействие мастер-узел и узел-узел внутри группы безопасности."
    predefined_target = "self_security_group"
    from_port         = 0
    to_port           = 65535
  }
  ingress {
    protocol          = "ANY"
    description       = "Правило разрешает взаимодействие под-под и сервис-сервис. Укажите подсети вашего кластера Managed Service for Kubernetes и сервисов."
    v4_cidr_blocks    = concat(yandex_vpc_subnet.default-ru-central1-a.v4_cidr_blocks)
    from_port         = 0
    to_port           = 65535
  }
  ingress {
    protocol          = "ICMP"
    description       = "Правило разрешает отладочные ICMP-пакеты из внутренних подсетей."
    v4_cidr_blocks    = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  }
  ingress {
    protocol          = "TCP"
    description       = "Правило разрешает входящий трафик из интернета на диапазон портов NodePort. Добавьте или измените порты на нужные вам."
    v4_cidr_blocks    = ["0.0.0.0/0"]
    from_port         = 30000
    to_port           = 32767
  }
  egress {
    protocol          = "ANY"
    description       = "Правило разрешает весь исходящий трафик. Узлы могут связаться с Yandex Container Registry, Yandex Object Storage, Docker Hub и т. д."
    v4_cidr_blocks    = ["0.0.0.0/0"]
    from_port         = 0
    to_port           = 65535
  }
}

resource "yandex_vpc_security_group" "k8s-master-whitelist" {
  name        = "k8s-master-whitelist"
  description = "Правила группы разрешают доступ к API Kubernetes из интернета. Примените правила только к кластеру."
  network_id  = yandex_vpc_network.default.id

  ingress {
    protocol       = "TCP"
    description    = "Правило разрешает подключение к API Kubernetes через порт 6443 из указанной сети."
    v4_cidr_blocks = ["46.188.123.160/32"]
    port           = 6443
  }

  ingress {
    protocol       = "TCP"
    description    = "Правило разрешает подключение к API Kubernetes через порт 443 из указанной сети."
    v4_cidr_blocks = ["46.188.123.160/32"]
    port           = 443
  }
}
