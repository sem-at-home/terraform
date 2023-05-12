module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "sem-vpc"
  cidr = "10.23.0.0/16"

  azs             = ["eu-west-1a"]
  private_subnets = ["10.23.1.0/24"]
  public_subnets  = ["10.23.101.0/24"]
}