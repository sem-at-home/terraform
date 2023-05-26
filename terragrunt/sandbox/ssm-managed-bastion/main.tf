data "aws_ami" "ubuntu_image" {
  most_recent = true
  filter {
    name   = "image-id"
    values = ["ami-0546127e0cf2c6498"] //Paris ami
  }
  owners = ["amazon"]
}

data "aws_iam_role" "amazon_ssm_ec2_role" {
  name = "AmazonSSMRoleForInstancesQuickSetup"
}

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "ssm_instance_profile"
  role = data.aws_iam_role.amazon_ssm_ec2_role.name
}

module "vpc" {
  source = "../network"
}

resource "aws_security_group" "ssm_instance_security_group" {
  name        = "ssm_instance_security_group"
  vpc_id      = module.vpc.vpc_id
  description = "Allows access to Web Port"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_egress_rule" "example" {
  security_group_id = aws_security_group.ssm_instance_security_group.id
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = -1 //all protocols
}

resource "aws_instance" "ssm_instance" {
  ami                    = data.aws_ami.ubuntu_image.id
  instance_type          = "t3.micro"
  subnet_id              = module.vpc.private_subnet
  iam_instance_profile   = aws_iam_instance_profile.ssm_instance_profile.name
  vpc_security_group_ids = [aws_security_group.ssm_instance_security_group.id]
  tags = {
    "Name" = "ssm_instance"
  }
}