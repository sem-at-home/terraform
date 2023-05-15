terraform {
  source = "../../modules//iam-identity-center"
}

include {
  path = find_in_parent_folders()
}