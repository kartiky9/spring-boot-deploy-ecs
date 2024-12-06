variable "vpc_id" {}
variable "client" {}
variable "environment" {}
variable "region" {}

variable "vpc_cidr" {}

variable "subnet_db_private" {
  type    = list(any)
  default = []
}
