# Generated by Terragrunt. Sig: nIlQXj57tbuaRZEa
terraform {
  backend "s3" {
    bucket  = "sem-896653224309-terraform-state-bucket"
    encrypt = true
    key     = "sandbox/ssm-maintenance-window/terraform.tfstate"
    region  = "eu-west-1"
  }
}
