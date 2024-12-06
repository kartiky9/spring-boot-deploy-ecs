# Net module output
output "vpc_id" {
  value = module.network.vpc
}
output "web_subnet_public" {
  value = module.network.web_subnet_public
}
output "nat_subnet_public" {
  value = module.network.nat_subnet_public
}
output "webhooks_subnet_public" {
  value = module.network.webhooks_subnet_public
}
output "db_subnet_private" {
  value = module.network.db_subnet_private
}
output "db_subnet_group" {
  value = module.network.db_subnet_group
}

# Sec module output
output "security_group_web" {
  value = module.security.security_group_web
}
output "security_group_ecs" {
  value = module.security.security_group_ecs
}
output "security_group_ecs_webhooks" {
  value = module.security.security_group_ecs_webhooks
}
output "security_group_db" {
  value = module.security.security_group_db
}

output "secrets_arn" {
  value = aws_secretsmanager_secret.backend.arn
}
output "secrets_kms_arn" {
  value = aws_kms_key.secretsmanager.arn
}
