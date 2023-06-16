module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "sem-vpc"
  cidr = "10.23.0.0/16"

  enable_nat_gateway = var.enable_nat_gateway

  azs             = var.availability_zones
  private_subnets = ["10.23.1.0/24", "10.23.2.0/24"]
  public_subnets  = ["10.23.101.0/24", "10.23.102.0/24"]
}