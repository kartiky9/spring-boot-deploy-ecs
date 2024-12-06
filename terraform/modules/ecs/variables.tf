variable "region" {}
variable "client" {}
variable "environment" {}

variable "vpc_id" {}
variable "subnets_web" {
  type    = list(any)
  default = []
}
variable "subnets_web_cidr" {}
variable "subnets_db" {
  type    = list(any)
  default = []
}
variable "subnets_webhooks" {
  type    = list(any)
  default = []
}
variable "subnets_nat_public" {
  type    = list(any)
  default = []
}

variable "backend_domain" {}
variable "webhooks_domain_prefix" {
  type    = string
  default = "webhooks"
}

variable "security_group_web" {}
variable "security_group_ecs" {}
variable "security_group_ecs_webhooks" {}

variable "db_url" {}
variable "db_port" {}

variable "tasks_count" {
  default = 0
}
variable "webhooks_tasks_count" {}
variable "repl_tasks_count" {}
variable "tasks_count_min" {
  default = 1
}
variable "tasks_count_max" {
  default = 6
}

variable "tg_deregistration_delay" {
  default = 120
}

variable "secrets_arn" {}
variable "secrets_kms_arn" {}

variable "clojure_socket_server" {
  default = ""
}
variable "ecs_cognito_dev_access" {}

variable "ecs_platform_version" {
  default = "1.4.0"
}

variable "server_port" {
  default = 8443
}
variable "repl_port" {
  default = 5555
}
variable "mis_port" {
  default = 8080
}

variable "webhooks_server_port" {
  default = 8443
}
variable "webhooks_repl_port" {
  default = 5050
}

variable "autoscaling_cpu_threshold" {
  default = 75
}
variable "autoscaling_memory_threshold" {
  default = 80
}
variable "autoscaling_requests_threshold" {
  default = 500
}

# Valid combinations of CPU/memory:
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html
variable "task_cpu_limit" {}
variable "task_memory_limit" {}
variable "webhooks_task_cpu_limit" {}
variable "webhooks_task_memory_limit" {}

variable "vector_image_tag" {
  default = "0.17.3-alpine"
}

variable "cognito_region" {}
variable "cognito_user_pool_id" {}
variable "cognito_user_pool_client_id" {}
variable "cognito_user_pool_arn" {}

variable "public_s3_write_policy_arn" {}
variable "private_s3_write_policy_arn" {}
variable "public_s3_bucket_name" {}
variable "private_docs_s3_bucket_name" {}
variable "public_s3_custom_domain" {}
