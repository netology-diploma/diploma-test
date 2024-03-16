variable "repository" {
  default = "git@github.com/netology-diploma/diploma-test"
}

variable "domain" {
  default = "tasenko.ru"
}

variable "service_account_key_file" {
  type    = string
  var     = YC_SERVICE_ACCOUNT_KEY_FILE
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

