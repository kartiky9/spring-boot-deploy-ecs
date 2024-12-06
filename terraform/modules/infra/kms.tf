resource "aws_kms_key" "secretsmanager" {
  enable_key_rotation = true

  policy = <<EOF
{
    "Version" : "2012-10-17",
    "Id" : "${var.client}-secretsmanager",
    "Statement" : [ 
        {
            "Sid" : "Allow access through AWS Secrets Manager for all principals in the account that are authorized to use AWS Secrets Manager",
            "Effect" : "Allow",
            "Principal" : {
                "AWS" : "*"
            },
            "Action" : [
                 "kms:Encrypt",
                 "kms:Decrypt",
                 "kms:ReEncrypt*",
                 "kms:GenerateDataKey*",
                 "kms:CreateGrant",
                 "kms:DescribeKey"
            ],
            "Resource" : "*",
            "Condition" : {
                "StringEquals" : {
                    "kms:ViaService" : "secretsmanager.${var.region}.amazonaws.com",
                    "kms:CallerAccount" : "${data.aws_caller_identity.current.account_id}"
                }
            }
        },
        {
            "Sid": "Allow direct access to key metadata to the account",
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
                ]

            },
            "Action": "kms:*",
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_kms_alias" "secretsmanager" {
  name          = "alias/${var.client}-${var.environment}-secretsmanager"
  target_key_id = aws_kms_key.secretsmanager.key_id
}
