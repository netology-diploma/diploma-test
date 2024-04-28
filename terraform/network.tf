resource "yandex_vpc_network" "kuber-network" {
  name = "kuber-${var.environment}"
}

resource "yandex_vpc_subnet" "public-subnet-1a" {
  zone           = var.zone_1a
  v4_cidr_blocks = [var.public_cidr_1a]
  network_id     = yandex_vpc_network.kuber-network.id
}

resource "yandex_vpc_subnet" "public-subnet-1b" {
  zone           = var.zone_1b
  v4_cidr_blocks = [var.public_cidr_1b]
  network_id     = yandex_vpc_network.kuber-network.id
}

resource "yandex_vpc_subnet" "public-subnet-1c" {
  zone           = var.zone_1c
  v4_cidr_blocks = [var.public_cidr_1c]
  network_id     = yandex_vpc_network.kuber-network.id
}

resource "yandex_vpc_subnet" "public-subnet-1d" {
  zone           = var.zone_1d
  v4_cidr_blocks = [var.public_cidr_1d]
  network_id     = yandex_vpc_network.kuber-network.id
}

resource "yandex_vpc_security_group" "k8s-public-services" {
  name        = "k8s-public-${var.environment}"
  description = "Правила группы разрешают подключение к сервисам из интернета. Примените правила только для групп узлов."
  network_id  = yandex_vpc_network.kuber-network.id
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
    v4_cidr_blocks    = concat(yandex_vpc_subnet.public-subnet-1a.v4_cidr_blocks)
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
  name        = "k8s-master-${var.environment}"
  description = "Правила группы разрешают доступ к API Kubernetes из интернета. Примените правила только к кластеру."
  network_id  = yandex_vpc_network.kuber-network.id

  ingress {
    protocol       = "TCP"
    description    = "Правило разрешает подключение к API Kubernetes через порт 6443 из указанной сети."
    v4_cidr_blocks = [var.client_network]
    port           = 6443
  }

  ingress {
    protocol       = "TCP"
    description    = "Правило разрешает подключение к API Kubernetes через порт 443 из указанной сети."
    v4_cidr_blocks = [var.client_network]
    port           = 443
  }
}
