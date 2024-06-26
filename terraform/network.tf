resource "yandex_vpc_network" "kuber-network" {
  name = "kuber-${var.environment}"
}

resource "yandex_vpc_subnet" "subnets" {
  for_each       = var.subnets
  name           = each.key
  zone           = each.value.zone
  v4_cidr_blocks = each.value.v4_cidr_blocks
  network_id     = yandex_vpc_network.kuber-network.id
  route_table_id = yandex_vpc_route_table.public-nat.id
}

resource "yandex_vpc_gateway" "public-nat" {
  name        = "nat-gateway"
  folder_id   = var.folder_id
  description = "NAT gateway for node-group Internet access"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "public-nat" {
  name       = "nat-table"
  network_id = yandex_vpc_network.kuber-network.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.public-nat.id
  }
}

resource "yandex_vpc_security_group" "k8s-public-services" {
  name        = "k8s-public-${var.environment}"
  description = "Правила группы разрешают подключение к сервисам из интернета. Примените правила только для групп узлов."
  network_id  = yandex_vpc_network.kuber-network.id

  dynamic "ingress" {
    for_each = var.security_group_ingress_k8s_public
    content {
      protocol        = lookup(ingress.value, "protocol", null)
      description     = lookup(ingress.value, "description", null)
      port            = lookup(ingress.value, "port", null)
      from_port       = lookup(ingress.value, "from_port", null)
      to_port         = lookup(ingress.value, "to_port", null)
      v4_cidr_blocks  = lookup(ingress.value, "v4_cidr_blocks", null)
    }
  }
  dynamic "egress" {
    for_each = var.security_group_egress_k8s_public
    content {
      protocol       = lookup(egress.value, "protocol", null)
      description    = lookup(egress.value, "description", null)
      port           = lookup(egress.value, "port", null)
      from_port      = lookup(egress.value, "from_port", null)
      to_port        = lookup(egress.value, "to_port", null)
      v4_cidr_blocks = lookup(egress.value, "v4_cidr_blocks", null)
    }
  }
}

resource "yandex_vpc_security_group" "k8s-master-whitelist" {
  name        = "k8s-master-${var.environment}"
  description = "Правила группы разрешают доступ к API Kubernetes из интернета. Примените правила только к кластеру."
  network_id  = yandex_vpc_network.kuber-network.id

  dynamic "ingress" {
    for_each = var.security_group_ingress_k8s_master
    content {
      protocol       = lookup(ingress.value, "protocol", null)
      description    = lookup(ingress.value, "description", null)
      port           = lookup(ingress.value, "port", null)
      from_port      = lookup(ingress.value, "from_port", null)
      to_port        = lookup(ingress.value, "to_port", null)
      v4_cidr_blocks = lookup(ingress.value, "v4_cidr_blocks", null)
    }
  }
  dynamic "egress" {
    for_each = var.security_group_egress_k8s_master
    content {
      protocol       = lookup(egress.value, "protocol", null)
      description    = lookup(egress.value, "description", null)
      port           = lookup(egress.value, "port", null)
      from_port      = lookup(egress.value, "from_port", null)
      to_port        = lookup(egress.value, "to_port", null)
      v4_cidr_blocks = lookup(egress.value, "v4_cidr_blocks", null)
    }
  }
}
