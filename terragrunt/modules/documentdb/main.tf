module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "sem-vpc"
  cidr = "10.23.0.0/16"

  enable_nat_gateway = true

  azs             = ["eu-west-1a", "eu-west-1b"]
  private_subnets = ["10.23.1.0/24", "10.23.2.0/24"]
  public_subnets  = ["10.23.101.0/24", "10.23.102.0/24"]
}

resource "aws_docdb_subnet_group" "default" {
  name       = "main"
  subnet_ids = [module.vpc.private_subnets[0]]
}

resource "aws_docdb_cluster" "docdb" {
  cluster_identifier      = "my-docdb-cluster"
  db_subnet_group_name    = aws_docdb_subnet_group.default.name
  engine                  = "docdb"
  master_username         = "foo"
  master_password         = "mustbeeightchars"
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  skip_final_snapshot     = true
}