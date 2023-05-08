remote_state {
  backend = "s3"
  config = {
    bucket  = "sem-sandbox-terraform-state-bucket"
    encrypt = true
    key     = "${path_relative_to_include()}/terraform.tfstate"
    region  = "eu-west-1"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
}