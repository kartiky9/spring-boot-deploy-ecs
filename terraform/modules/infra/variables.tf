variable "region" {}
variable "client" {}
variable "environment" {}

variable "vpc_cidr" {}
variable "subnet_web_public" {
  type    = list(any)
  default = []
}
variable "subnet_db_private" {
  type    = list(any)
  default = []
}
variable "subnet_webhooks_public" {
  type    = list(any)
  default = []
}
