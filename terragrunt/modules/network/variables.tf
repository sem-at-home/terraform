variable enable_nat_gateway {
  type        = bool
  default     = true
}

variable availability_zones {
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b"]
}
