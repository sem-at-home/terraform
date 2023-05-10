resource "aws_ssm_maintenance_window" "patching_window" {
  name     = "maintenance-window-patching"
  schedule = "cron(30 * ? * * *)"
  duration = 2
  cutoff   = 1
}

resource "aws_ssm_maintenance_window_target" "tagged_instances_target" {
  window_id     = aws_ssm_maintenance_window.patching_window.id
  name          = "maintenance-window-target"
  description   = "This is a maintenance window target"
  resource_type = "INSTANCE"

  targets {
    key    = "tag:Name"
    values = ["tagged_instance"]
  }
}

data "aws_iam_role" "ssm_service_role" {
  name = "AWSServiceRoleForAmazonSSM"
}

resource "aws_ssm_document" "apt_update" {
  name            = "apt_update"
  document_format = "YAML"
  document_type   = "Command"

  content = <<DOC
schemaVersion: '1.2'
description: Run apt update on instance.
parameters: {}
runtimeConfig:
  'aws:runShellScript':
    properties:
      - id: '0.aws:runShellScript'
        runCommand:
          - apt update
DOC
}

resource "aws_ssm_maintenance_window_task" "apt_update_task" {
  max_concurrency  = 2
  max_errors       = 1
  priority         = 1
  service_role_arn = data.aws_iam_role.ssm_service_role.arn
  task_arn         = aws_ssm_document.apt_update.arn
  task_type        = "RUN_COMMAND"
  window_id        = aws_ssm_maintenance_window.patching_window.id

  targets {
    key    = "WindowTargetIds"
    values = [aws_ssm_maintenance_window_target.tagged_instances_target.id]
  }

  task_invocation_parameters {
    run_command_parameters {
      cloudwatch_config {
        cloudwatch_output_enabled = true
      }

    }
  }
}

data "aws_iam_role" "test_role" {
  name               = "AmazonSSMRoleForInstancesQuickSetup"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "image-id"
    values = ["ami-09fd16644beea3565"]
  }

  owners = ["amazon"]
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
}

resource "aws_iam_instance_profile" "test_profile" {
  name = "test_profile"
  role = data.aws_iam_role.test_role.name
}

data "template_file" "startup" {
  template = file("ssm-agent-install.sh")
}

resource "aws_security_group" "allow_web" {
  name        = "webserver"
  vpc_id      = module.vpc.vpc_id
  description = "Allows access to Web Port"
  #all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = module.vpc.private_subnets[1]
  iam_instance_profile   = aws_iam_instance_profile.test_profile.name
  # user_data              = data.template_file.startup.rendered
  vpc_security_group_ids = [aws_security_group.allow_web.id]

  tags = {
    "Name" = "tagged_instance"
  }
}