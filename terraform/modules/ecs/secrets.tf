data "aws_secretsmanager_secret" "by-arn" {
  arn = var.secrets_arn
}

data "aws_secretsmanager_secret_version" "this" {
  secret_id = data.aws_secretsmanager_secret.by-arn.id
}

locals {
  CRON_API_KEY = jsondecode(data.aws_secretsmanager_secret_version.this.secret_string)["CRON_API_KEY"]
}
