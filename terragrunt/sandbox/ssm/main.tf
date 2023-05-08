resource "aws_ssm_maintenance_window" "patching_window" {
  name     = "maintenance-window-application"
  schedule = "cron(0 4 ? * TUE *)"
  duration = 2
  cutoff   = 1
}

resource "aws_ssm_maintenance_window_target" "tagged_instances" {
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

resource "aws_ssm_document" "foo" {
  name            = "test_document"
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

resource "aws_ssm_maintenance_window_task" "example" {
  max_concurrency  = 2
  max_errors       = 1
  priority         = 1
  service_role_arn = data.aws_iam_role.ssm_service_role.arn
  task_arn         = aws_ssm_document.foo.arn
  task_type        = "RUN_COMMAND"
  window_id        = aws_ssm_maintenance_window.patching_window.id

  targets {
    key    = "WindowTargetIds"
    values = [aws_ssm_maintenance_window_target.tagged_instances.id]
  }
}