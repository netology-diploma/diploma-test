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

variable "subnets" {
  type    = list(any)
  default = [
    {
      name           = public-subnet-1a,
      zone           = var.zone_1a,
      v4_cidr_blocks = var.public_cidr_1a
    },
    {
      name           = public-subnet-1b,
      zone           = var.zone_1b,
      v4_cidr_blocks = var.public_cidr_1b
    },
    {
      name           = public-subnet-1c,
      zone           = var.zone_1c,
      v4_cidr_blocks = var.public_cidr_1c
    },
    {
      name           = public-subnet-1d,
      zone           = var.zone_1d,
      v4_cidr_blocks = var.public_cidr_1d
    }
  ]
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

variable "public_cidr_1a" {
  type    = list(string)
  default = ["10.0.11.0/24"]
}
variable "public_cidr_1b" {
  type    = list(string)
  default = ["10.0.12.0/24"]
}
variable "public_cidr_1c" {
  type    = list(string)
  default = ["10.0.13.0/24"]
}

variable "public_cidr_1d" {
  type    = list(string)
  default = ["10.0.14.0/24"]
}

variable "client_network" {
  type    = list(string)
  default = [
    "0.0.0.0/0",
    "46.188.123.160/32",
    "164.90.169.22/32"
  ]
}

variable "node_resources" {
  type     = map(number)
  default  = { cores = "2", memory = "4", core_fraction = "5" }
}
