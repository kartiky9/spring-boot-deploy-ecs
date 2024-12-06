variable "region" {}
variable "client" {}
variable "environment" {}

variable "vpc_cidr" {}
variable "subnet_web_public" {}
variable "subnet_db_private" {}
variable "subnet_webhooks_public" {}

variable "multi_az" {}
variable "backup_retention_period" {}


variable "tg_deregistration_delay" {
  default = 0
}

variable "task_cpu_limit" {
  default = "256"
}
variable "task_memory_limit" {
  default = "512"
}
