resource "aws_secretsmanager_secret" "backend" {
  name = "${var.environment}/backend-secrets"

  kms_key_id              = aws_kms_key.secretsmanager.arn
  recovery_window_in_days = 30
}

# resource "aws_secretsmanager_secret_version" "rds_init" {
#   secret_id = aws_secretsmanager_secret.backend.id
#   secret_string = jsonencode(
#     {
#       "engine"   = "postgres"
#       "host"     = "not-used"
#       "username" = "${var.client}_${var.environment}"
#       "password" = "init-password"
#       "dbname"   = "${var.client}_${var.environment}"
#     }
#   )
# }

# resource "aws_secretsmanager_secret_rotation" "rds" {
#   secret_id           = aws_secretsmanager_secret.backend.id
#   rotation_lambda_arn = aws_lambda_function.rds_secrets_rotation.arn

#   rotation_rules {
#     automatically_after_days = 30
#   }
# }
