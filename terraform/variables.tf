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
  type    = map(object({
    name           = string
    zone           = string
    v4_cidr_blocks = string
  }))
  default = {
    public-subnet-1a = {
      name           = "public-subnet-1a",
      zone           = "ru-central1-a",
      v4_cidr_blocks = "10.0.11.0/24"
    }
    public-subnet-1b = {
      name           = "public-subnet-1b",
      zone           = "ru-central1-b",
      v4_cidr_blocks = "10.0.12.0/24"
    }
    public-subnet-1c = {
      name           = "public-subnet-1c",
      zone           = "ru-central1-c",
      v4_cidr_blocks = "10.0.13.0/24"
    }
    public-subnet-1d = {
      name           = "public-subnet-1d",
      zone           = "ru-central1-d",
      v4_cidr_blocks = "10.0.14.0/24"
    }
  }
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
