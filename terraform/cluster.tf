resource "yandex_kubernetes_cluster" "diploma" {
  name       = "yandex-k8s-${var.environment}"
  network_id = yandex_vpc_network.kuber-network.id

  master {
    regional {
      region = var.region
#      location {
#        zone      = [for value in yandex_vpc_subnet.subnets: value.zone]
#        subnet_id = [for value in yandex_vpc_subnet.subnets: value.id]
#      }
    }
    version   = var.k8s_version
    public_ip = var.k8s_is_public_ip
    security_group_ids = [
      yandex_vpc_security_group.k8s-master-whitelist.id,
      yandex_vpc_security_group.k8s-public-services.id
    ]

    maintenance_policy {
      auto_upgrade = true
      maintenance_window {
        day        = var.k8s_maintenance.day
        start_time = var.k8s_maintenance.start_time
        duration   = var.k8s_maintenance.duration
      }
    }
  }

  service_account_id      = yandex_iam_service_account.cluster-sa.id
  node_service_account_id = yandex_iam_service_account.cluster-sa.id
  depends_on = [
    yandex_resourcemanager_folder_iam_member.sa-roles
  ]

  kms_provider {
    key_id = yandex_kms_symmetric_key.kms-key.id
  }
}

resource "yandex_kubernetes_node_group" "diploma-nodes" {
  cluster_id = yandex_kubernetes_cluster.diploma.id
  name       = "nodes-diploma-${var.environment}"
  version    = var.k8s_version

  allocation_policy {
    location {
      zone = var.zone_1a
    }
  }

  instance_template {
    name        = "${var.environment}-{instance.short_id}"
    platform_id = var.node_group_platform_id

    resources {
      memory        = var.node_group_resources.memory
      cores         = var.node_group_resources.cores
      core_fraction = var.node_group_resources.core_fraction
    }

    boot_disk {
      type = var.node_group_boot_disk.type
      size = var.node_group_boot_disk.size
    }

    network_interface {
      nat                = var.node_group_is_nat
      subnet_ids         = [yandex_vpc_subnet.subnets["public-subnet-1a"].id]
      security_group_ids = [yandex_vpc_security_group.k8s-public-services.id]
    }

    network_acceleration_type = var.node_group_network_acceleration

    scheduling_policy {
      preemptible = var.node_group_scheduling
    }

    container_runtime {
      type = var.node_group_container_runtime
    }
  }

  scale_policy {
    auto_scale {
      initial = var.node_group_autoscale.initial
      max     = var.node_group_autoscale.max
      min     = var.node_group_autoscale.min
    }
  }
}
