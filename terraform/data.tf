data "terraform_remote_state" "diploma-test" {
  backend = "remote"
  config = {
    organization = "fenixcorp"
    workspaces = {
      name = "diploma-test"
    }
  }
}

data "yandex_compute_image" "my_image" {
  family = var.image_family
}
