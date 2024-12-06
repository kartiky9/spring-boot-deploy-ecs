module "core_infra" {
  source = "../modules/infra"

  region      = var.region
  client      = var.client
  environment = var.environment

  vpc_cidr          = var.vpc_cidr
  subnet_web_public = var.subnet_web_public
  subnet_db_private = var.subnet_db_private

  datascience_vpc = var.datascience_vpc

  ec2_key_name   = var.ec2_key_name
  backend_domain = var.backend_domain

  decentro_ip_address = var.decentro_ip_address
  vapt_ip_address     = var.vapt_ip_address
}


module "ecs" {
  source = "../modules/ecs"
  providers = {
    aws.ecr-region = aws.default-region
  }

  region      = var.region
  client      = var.client
  environment = var.environment

  subnets_web        = module.core_infra.web_subnet_public
  subnets_webhooks   = module.core_infra.webhooks_subnet_public
  subnets_db         = module.core_infra.db_subnet_private
  subnets_nat_public = module.core_infra.nat_subnet_public

  subnets_web_cidr = var.subnet_web_public
  vpc_id           = module.core_infra.vpc_id

  security_group_web          = module.core_infra.security_group_web
  security_group_ecs          = module.core_infra.security_group_ecs
  security_group_ecs_webhooks = module.core_infra.security_group_ecs_webhooks

  db_url  = module.db.db_endpoint
  db_port = module.db.db_port

  secrets_arn     = module.core_infra.secrets_arn
  secrets_kms_arn = module.core_infra.secrets_kms_arn

  clojure_socket_server  = var.clojure_socket_server
  ecs_cognito_dev_access = var.ecs_cognito_dev_access

  tg_deregistration_delay = var.tg_deregistration_delay

  cognito_region              = var.region
  cognito_user_pool_id        = module.cognito.user_pool_id
  cognito_user_pool_client_id = module.cognito.user_pool_client_id
  cognito_user_pool_arn       = module.cognito.user_pool_arn

  public_s3_bucket_name       = module.storage.public_s3_bucket_name
  private_docs_s3_bucket_name = module.storage.private_doc_s3_bucket_name
  public_s3_custom_domain     = module.storage.avatars_s3_custom_domain
  public_s3_write_policy_arn  = module.storage.public_s3_write_policy_arn
  private_s3_write_policy_arn = module.storage.private_s3_write_policy_arn

  webhooks_tasks_count       = var.webhooks_tasks_count
  repl_tasks_count           = var.repl_tasks_count
  task_cpu_limit             = var.task_cpu_limit
  task_memory_limit          = var.task_memory_limit
  webhooks_task_cpu_limit    = var.webhooks_task_cpu_limit
  webhooks_task_memory_limit = var.webhooks_task_memory_limit
}


# Database for application
# module "db" {
# source = "../modules/db"
# }

# S3, S3 Glaciers
# module "storage" {
# source = "../modules/storage"
# }
