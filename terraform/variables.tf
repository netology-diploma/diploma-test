variable "repository" {
  description = "Diploma repository"
  default     = "diploma-test"
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

variable "cloud_id" {
  type    = string
}

variable "folder_id" {
  type    = string
}

variable "environment" {
  type    = string
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
    "75.2.98.97/32",
    "99.83.150.238/32",
    "46.188.123.160/32",
    "164.90.169.22/32"
  ]
}

variable "node_resources" {
  type = map(number)
  default  = { cores = "2", memory = "4", core_fraction = "5" }
}
