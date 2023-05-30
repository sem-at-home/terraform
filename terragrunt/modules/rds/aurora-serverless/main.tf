resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = [data.aws_subnet.default.id]

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_rds_cluster" "default" {
  availability_zones      = ["eu-west-1a", "eu-west-1a"]
  backup_retention_period = 5
  cluster_identifier      = "aurora-cluster-demo"
  database_name           = "mydb"
  db_subnet_group_name    = aws_db_subnet_group.default.name
  engine                  = "aurora-mysql"
  engine_mode             = "provisioned"
  engine_version          = "5.7.mysql_aurora.2.07.1"

  master_username         = "foo"
  master_password         = "bar"

  preferred_backup_window = "07:00-09:00"

  serverlessv2_scaling_configuration {
    max_capacity = 1.0
    min_capacity = 0.5
  }
}