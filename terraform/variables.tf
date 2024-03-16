variable "repository" {
  default = "git@github.com/netology-diploma/diploma-test"
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

variable "image_family" {
  type    = string
  default = "ubuntu-2004-lts"
}

