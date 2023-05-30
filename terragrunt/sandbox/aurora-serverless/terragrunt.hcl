include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../modules/rds//aurora-serverless"
}

inputs = {
  subnet_id = "subnet-04870ed17975eb72f"
}

