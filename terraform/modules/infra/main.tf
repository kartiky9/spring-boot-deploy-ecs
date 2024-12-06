data "aws_caller_identity" "current" {}

module "network" {
  source      = "./network"
  client      = var.client
  environment = var.environment

  vpc_cidr          = var.vpc_cidr
  subnet_web_public = var.subnet_web_public
  subnet_db_private = var.subnet_db_private
}

module "security" {
  source      = "./sec"
  vpc_id      = module.network.vpc
  client      = var.client
  environment = var.environment
  region      = var.region

  vpc_cidr          = var.vpc_cidr
  subnet_db_private = var.subnet_db_private

}


resource "aws_cloudwatch_log_group" "vpc" {
  name              = "${var.client}-${var.environment}-VPCflowLog"
  retention_in_days = 7
}

data "aws_iam_role" "main" {
  name = "${var.client}-vpcFlowLogsRole"
}

resource "aws_flow_log" "vpc" {
  iam_role_arn    = data.aws_iam_role.main.arn
  log_destination = aws_cloudwatch_log_group.vpc.arn
  traffic_type    = "ALL"
  vpc_id          = module.network.vpc
}
