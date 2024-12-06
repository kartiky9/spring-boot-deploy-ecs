locals {
  ses_policy_resource = replace(data.terraform_remote_state.spring-common.outputs.aws_ses_domain_identity_verification_arn, data.terraform_remote_state.spring-common.outputs.aws_ses_domain_identity_id, "*")
}

data "aws_iam_group" "cicd" {
  group_name = "CICD"
}

resource "aws_iam_role" "ecs-task" {
  name = "${var.client}-${var.environment}-ecsTaskRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "ecs-cognito" {
  name = "${var.client}-${var.environment}-ecs-cognito-access"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "cognito-idp:AdminGetUser",
        "cognito-idp:AdminUpdateUserAttributes",
        "cognito-idp:ListUsers"
      ],
      "Effect": "Allow",
      "Resource": "${var.cognito_user_pool_arn}"
    },
    {
      "Action": [
        "cognito-idp:UpdateUserAttributes"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "ecs-cognito-extended" {
  name = "${var.client}-${var.environment}-ecs-cognito-extended-access"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "cognito-idp:AdminCreateUser",
        "cognito-idp:AdminDeleteUser",
        "cognito-idp:AdminSetUserPassword"
      ],
      "Effect": "Allow",
      "Resource": "${var.cognito_user_pool_arn}"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs-cognito-access" {
  role       = aws_iam_role.ecs-task.id
  policy_arn = aws_iam_policy.ecs-cognito.arn
}

resource "aws_iam_role_policy_attachment" "ecs-cognito-extended-access" {
  count      = var.ecs_cognito_dev_access != "" ? 1 : 0
  role       = aws_iam_role.ecs-task.id
  policy_arn = aws_iam_policy.ecs-cognito-extended.arn
}

resource "aws_iam_role_policy_attachment" "ecs-private-s3-access" {
  role       = aws_iam_role.ecs-task.id
  policy_arn = var.private_s3_write_policy_arn
}

resource "aws_iam_role_policy_attachment" "ecs-public-s3-access" {
  role       = aws_iam_role.ecs-task.id
  policy_arn = var.public_s3_write_policy_arn
}

resource "aws_iam_role" "ecs-execution" {
  name = "${var.client}-${var.environment}-ecsTaskExecutionRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "ecs-secrets" {
  name = "${var.client}-${var.environment}-ecs-secrets-access"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue",
        "kms:Decrypt"
      ],
      "Resource": [
        "${var.secrets_arn}",
        "${var.secrets_kms_arn}"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs-attachment-secrets" {
  role       = aws_iam_role.ecs-execution.name
  policy_arn = aws_iam_policy.ecs-secrets.arn
}

data "aws_iam_policy" "AmazonECSTaskExecutionRolePolicy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs-attachment" {
  role       = aws_iam_role.ecs-execution.name
  policy_arn = data.aws_iam_policy.AmazonECSTaskExecutionRolePolicy.arn
}


resource "aws_iam_policy" "ecs-deploy" {
  name        = "${var.client}-${var.environment}-ECS-RegisterTaskDefinition"
  path        = "/"
  description = "ECS Deploy permissions for ${var.environment}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
        "iam:PassRole"
      ],
      "Resource": [
        "${aws_iam_role.ecs-task.arn}",
        "${aws_iam_role.ecs-execution.arn}"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_group_policy_attachment" "ecs-deploy" {
  group      = data.aws_iam_group.cicd.group_name
  policy_arn = aws_iam_policy.ecs-deploy.arn
}
