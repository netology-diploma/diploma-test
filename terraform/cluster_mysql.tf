resource "yandex_mdb_mysql_cluster" "mysql" {
  name        = "mysql"
  environment = "PRESTABLE"
  network_id  = yandex_vpc_network.kuber-network.id
  version     = "8.0"
  deletion_protection = true

  resources {
    resource_preset_id = "b1.medium"
    disk_type_id       = "network-ssd"
    disk_size          = 20
  }

  maintenance_window {
    type = "ANYTIME"
  }

  backup_window_start {
    hours   = 23
    minutes = 59
  }

  host {
    zone      = var.zone_1a
    subnet_id = yandex_vpc_subnet.private-subnet-1a.id
  }

  host {
    zone      = var.zone_1b
    subnet_id = yandex_vpc_subnet.private-subnet-1b.id
  }

  security_group_ids = [yandex_vpc_security_group.mysql-sg.id]
}

resource "yandex_mdb_mysql_database" "clopro" {
  cluster_id = yandex_mdb_mysql_cluster.mysql.id
  name       = "clopro"
}

variable "clopro-user" {
  type    = string
}

resource "yandex_mdb_mysql_user" "clopro-user" {
  cluster_id = yandex_mdb_mysql_cluster.mysql.id
  name       = "clopro"
  password   = var.clopro-user

  permission {
    database_name = yandex_mdb_mysql_database.clopro.name
    roles         = ["ALL"]
  }
}
