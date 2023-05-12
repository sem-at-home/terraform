data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "image-id"
    values = ["ami-09fd16644beea3565"]
  }
  owners = ["amazon"]
}

data "aws_iam_role" "amazon_ssm_ec2_role" {
  name               = "AmazonSSMRoleForInstancesQuickSetup"
}

resource "aws_iam_instance_profile" "test_profile" {
  name = "test_profile"
  role = data.aws_iam_role.amazon_ssm_ec2_role.name
}

module "vpc" {
  source = "../network"
}

resource "aws_security_group" "allow_web" {
  name        = "webserver"
  vpc_id      = module.vpc.vpc_id
  description = "Allows access to Web Port"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = module.vpc.private_subnet
  iam_instance_profile   = aws_iam_instance_profile.test_profile.name
  vpc_security_group_ids = [aws_security_group.allow_web.id]
  tags = {
    "Name" = "tagged_instance"
  }
}