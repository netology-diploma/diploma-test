# Common variables
variable "repository" {
  description = "Diploma repository"
  default     = "diploma-test-app"
}

variable "github_token" {
  description = "GitHub token"
  sensitive   = true
  type        = string
}

variable "github_org" {
  description = "GitHub organization"
  type        = string
  default     = "netology-diploma"
}

variable "domain" {
  default = "tasenko.ru"
}

variable "YC_SERVICE_ACCOUNT_KEY_FILE" {
  type    = string
}

variable "CF_API_TOKEN" {
  type    = string
}

variable "cloud_id" {
  type    = string
}

variable "folder_id" {
  type    = string
}

variable "environment" {
  type    = string
}

# Region and network-related variables
variable "subnets" {
  type    = map(object({
    name           = string
    zone           = string
    v4_cidr_blocks = list(string)
  }))
  default = {
    public-subnet-1a = {
      name           = "public-subnet-1a",
      zone           = "ru-central1-a",
      v4_cidr_blocks = ["10.0.11.0/24"]
    }
    public-subnet-1b = {
      name           = "public-subnet-1b",
      zone           = "ru-central1-b",
      v4_cidr_blocks = ["10.0.12.0/24"]
    }
    public-subnet-1d = {
      name           = "public-subnet-1d",
      zone           = "ru-central1-d",
      v4_cidr_blocks = ["10.0.13.0/24"]
    }
    public-subnet-1c = {
      name           = "public-subnet-1c",
      zone           = "ru-central1-c",
      v4_cidr_blocks = ["10.0.14.0/24"]
    }
  }
}

variable "region" {
  type    = string
  default = "ru-central1"
}

variable "zone_1a" {
  type    = string
  default = "ru-central1-a"
}

variable "zone_1b" {
  type    = string
  default = "ru-central1-b"
}
variable "zone_1c" {
  type    = string
  default = "ru-central1-c"
}

variable "zone_1d" {
  type    = string
  default = "ru-central1-d"
}

variable "security_group_ingress_k8s_public" {
  type = list(object(
    {
      protocol          = string
      description       = optional(string)
      v4_cidr_blocks    = optional(list(string))
      port              = optional(number)
      from_port         = optional(number)
      to_port           = optional(number)
      predefined_target = optional(string)
      }))
  default = [
    {
      protocol          = "TCP"
      description       = "Правило разрешает проверки доступности с диапазона адресов балансировщика нагрузки. Нужно для работы отказоустойчивого кластера Managed Service for Kubernetes и сервисов балансировщика."
      predefined_target = "loadbalancer_healthchecks"
      from_port         = 0
      to_port           = 65535
    },
    {
      protocol          = "ANY"
      description       = "Правило разрешает взаимодействие мастер-узел и узел-узел внутри группы безопасности."
      predefined_target = "self_security_group"
      from_port         = 0
      to_port           = 65535
    },
    {
      protocol          = "ANY"
      description       = "Правило разрешает взаимодействие под-под и сервис-сервис. Укажите подсети вашего кластера Managed Service for Kubernetes и сервисов."
      v4_cidr_blocks    = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24", "10.0.14.0/24"]
      from_port         = 0
      to_port           = 65535
    },
    {
      protocol          = "ICMP"
      description       = "Правило разрешает отладочные ICMP-пакеты из внутренних подсетей."
      v4_cidr_blocks    = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
    },
    {
      protocol          = "TCP"
      description       = "Правило разрешает входящий трафик из интернета на диапазон портов NodePort. Добавьте или измените порты на нужные вам."
      v4_cidr_blocks    = ["0.0.0.0/0"]
      from_port         = 30000
      to_port           = 32767
    }
  ]
}

variable "security_group_egress_k8s_public" {
  type = list(object(
    {
      protocol          = string
      description       = optional(string)
      v4_cidr_blocks    = optional(list(string))
      port              = optional(number)
      from_port         = optional(number)
      to_port           = optional(number)
      }))
  default = [
    {
      protocol          = "ANY"
      description       = "Правило разрешает весь исходящий трафик. Узлы могут связаться с Yandex Container Registry, Yandex Object Storage, Docker Hub и т. д."
      v4_cidr_blocks    = ["0.0.0.0/0"]
      from_port         = 0
      to_port           = 65535
    }
  ]
}

variable "security_group_ingress_k8s_master" {
  type = list(object(
    {
      protocol          = string
      description       = string
      v4_cidr_blocks    = optional(list(string))
      port              = optional(number)
      from_port         = optional(number)
      to_port           = optional(number)
      predefined_target = optional(string)
      }))
  default = [
    {
      protocol       = "TCP"
      description    = "Правило разрешает подключение к API Kubernetes через порт 6443 из указанной сети."
      v4_cidr_blocks = ["0.0.0.0/0"]
      port           = 6443
    },
    {
      protocol       = "TCP"
      description    = "Правило разрешает подключение к API Kubernetes через порт 443 из указанной сети."
      v4_cidr_blocks = ["0.0.0.0/0"]
      port           = 443
    }
  ]
}

variable "security_group_egress_k8s_master" {
  type = list(object(
    {
      protocol          = string
      description       = string
      v4_cidr_blocks    = list(string)
      port              = optional(number)
      from_port         = optional(number)
      to_port           = optional(number)
      }))
  default = []
}

# Kubernetes cluster-related variables
variable "k8s_sa_roles" {
  type    = set(string)
  default = [
    "editor",
    "load-balancer.admin",
    "k8s.clusters.agent",
    "vpc.publicAdmin",
    "container-registry.images.puller",
    "kms.keys.encrypterDecrypter"
  ]
}

variable "k8s_version" {
  type    = string
  default = "1.28"
}

variable "k8s_is_public_ip" {
  type    = bool
  default = true
}

variable "k8s_maintenance" {
  type         = map(string)
  default      = {
    day        = "monday",
    start_time = "23:00",
    duration   = "3h"
  }
}

# Kubernetes node-group-related variables
variable "node_group_platform_id" {
  type    = string
  default = "standard-v2"
}

variable "node_group_resources" {
  type            = map(number)
  default         = {
    cores         = "2",
    memory        = "4",
    core_fraction = "5"
  }
}

variable "node_group_boot_disk" {
  type    = map(string)
  default = {
    type  = "network-hdd",
    size  = "64"
  }
}

variable "node_group_is_nat" {
  type    = bool
  default = false
}

variable "node_group_network_acceleration" {
  type    = string
  default = "standard"
}

variable "node_group_scheduling" {
  type    = bool
  default = true
}

variable "node_group_container_runtime" {
  type    = string
  default = "containerd"
}

variable "node_group_autoscale" {
  type      = map(number)
  default   = {
    initial = 2,
    max     = 6,
    min     = 2
  }
}
