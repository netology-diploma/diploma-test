data "terraform_remote_state" "diploma-test" {
  backend = "remote"

  config = {
    organization = "fenixcorp"

    workspaces = {
      name = "diploma-test"
    }
  }
}
