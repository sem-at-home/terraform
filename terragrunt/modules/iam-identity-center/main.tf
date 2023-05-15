
module "engineer_group" {
  source = "./iam-identity-center-group"
  display_name = "Engineers"
  description = "All engineers will be in this group"
}

module "john_doe" {
  source = "./iam-identity-center-user"
  email = "john@email.com"
  given_name = "John"
  family_name = "Doe"
  groups = {
    engineer = module.engineer_group.group_id
  }
}

module "power_user_permission_set" {
  source = "./iam-identity-center-permission-set"
  name = "power-user-access"
  description = "permission set for power user access"
  managed_policy_arns = {
    power_user = "arn:aws:iam::aws:policy/PowerUserAccess"
  }
}

module "engineer_power_user_assignment" {
  source = "./iam-identity-center-assignment"
  permission_set_arn = module.power_user_permission_set.permission_set_arn
  group_id = module.engineer_group.group_id
  account_ids = {
    management = "909183324734"
  }
}

