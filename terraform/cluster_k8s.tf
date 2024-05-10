resource "yandex_kubernetes_cluster" "diploma" {
  name = "yandex-k8s-${var.environment}"
  network_id = yandex_vpc_network.kuber-network.id

  master {
    regional {
      region = "ru-central1"
      location {
        zone      = yandex_vpc_subnet.public-subnet-1a.zone
        subnet_id = yandex_vpc_subnet.public-subnet-1a.id
      }
      location {
        zone      = yandex_vpc_subnet.public-subnet-1b.zone
        subnet_id = yandex_vpc_subnet.public-subnet-1b.id
      }
      location {
        zone      = yandex_vpc_subnet.public-subnet-1d.zone
        subnet_id = yandex_vpc_subnet.public-subnet-1d.id
      }
    }

    public_ip = true
    security_group_ids = [
      yandex_vpc_security_group.k8s-master-whitelist.id,
      yandex_vpc_security_group.k8s-public-services.id
    ]

    maintenance_policy {
      auto_upgrade = true
      maintenance_window {
        day        = "monday"
        start_time = "23:00"
        duration   = "3h"
      }
    }
  }

  service_account_id      = yandex_iam_service_account.cluster-sa.id
  node_service_account_id = yandex_iam_service_account.cluster-sa.id
  depends_on = [
    yandex_resourcemanager_folder_iam_member.k8s-clusters-agent,
    yandex_resourcemanager_folder_iam_member.vpc-public-admin,
    yandex_resourcemanager_folder_iam_member.images-puller,
    yandex_resourcemanager_folder_iam_member.encrypterDecrypter
  ]

  kms_provider {
    key_id = yandex_kms_symmetric_key.kms-key.id
  }
}

resource "yandex_kubernetes_node_group" "diploma-nodes" {
  cluster_id    = yandex_kubernetes_cluster.diploma.id
  name          = "nodes-diploma-${var.environment}"

  allocation_policy {
    location {
      zone = var.zone_1a
    }
  }

  instance_template {
    name        = "${var.environment}-{instance.short_id}"
    platform_id = "standard-v2"

    resources {
      memory        = var.node_resources.memory
      cores         = var.node_resources.cores
      core_fraction = var.node_resources.core_fraction
    }

    boot_disk {
      type = "network-hdd"
      size = 64
    }

    network_interface {
      nat                = false
      subnet_ids         = [yandex_vpc_subnet.public-subnet-1a.id]
      security_group_ids = [yandex_vpc_security_group.k8s-public-services.id]
    }

    network_acceleration_type = "standard"

    scheduling_policy {
      preemptible = true
    }

    container_runtime {
      type = "containerd"
    }
  }

  scale_policy {
    auto_scale {
      initial = 3
      max     = 6
      min     = 3
    }
  }
}
