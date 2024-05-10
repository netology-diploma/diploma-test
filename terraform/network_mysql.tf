variable "private_cidr_1a" {
  type    = list(string)
  default = ["10.0.21.0/24"]
}
variable "private_cidr_1b" {
  type    = list(string)
  default = ["10.0.22.0/24"]
}
variable "private_cidr_1c" {
  type    = list(string)
  default = ["10.0.23.0/24"]
}

variable "private_cidr_1d" {
  type    = list(string)
  default = ["10.0.24.0/24"]
}

resource "yandex_vpc_subnet" "private-subnet-1a" {
  zone           = var.zone_1a
  v4_cidr_blocks = var.private_cidr_1a
  network_id     = yandex_vpc_network.kuber-network.id
}

resource "yandex_vpc_subnet" "private-subnet-1b" {
  zone           = var.zone_1b
  v4_cidr_blocks = var.private_cidr_1b
  network_id     = yandex_vpc_network.kuber-network.id
}

resource "yandex_vpc_subnet" "private-subnet-1c" {
  zone           = var.zone_1c
  v4_cidr_blocks = var.private_cidr_1c
  network_id     = yandex_vpc_network.kuber-network.id
}

resource "yandex_vpc_subnet" "private-subnet-1d" {
  zone           = var.zone_1d
  v4_cidr_blocks = var.private_cidr_1d
  network_id     = yandex_vpc_network.kuber-network.id
}

resource "yandex_vpc_security_group" "mysql-sg" {
  name       = "mysql-sg"
  network_id = yandex_vpc_network.kuber-network.id

  ingress {
    description    = "MySQL"
    port           = 3306
    protocol       = "TCP"
    v4_cidr_blocks = [
      yandex_vpc_subnet.public-subnet-1a.v4_cidr_blocks,
      yandex_vpc_subnet.public-subnet-1b.v4_cidr_blocks,
      yandex_vpc_subnet.public-subnet-1c.v4_cidr_blocks,
      yandex_vpc_subnet.public-subnet-1d.v4_cidr_blocks
    ]
  }
}
