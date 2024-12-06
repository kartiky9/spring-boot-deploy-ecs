resource "aws_iam_policy" "cloudwatch_logs" {
  name        = "${var.client}-${var.environment}-cloudwatch_logs"
  path        = "/"
  description = "Access to ECS logs"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "logs:DescribeQueries",
                "logs:DescribeExportTasks",
                "logs:GetLogRecord",
                "logs:GetQueryResults",
                "logs:StopQuery",
                "logs:TestMetricFilter",
                "logs:DescribeResourcePolicies",
                "logs:GetLogDelivery",
                "logs:DescribeDestinations",
                "logs:ListLogDeliveries",
                "logs:DescribeLogGroups"
            ],
            "Resource": "*"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "logs:ListTagsLogGroup",
                "logs:DescribeQueries",
                "logs:GetLogRecord",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:DescribeSubscriptionFilters",
                "logs:StartQuery",
                "logs:DescribeMetricFilters",
                "logs:StopQuery",
                "logs:TestMetricFilter",
                "logs:GetLogDelivery",
                "logs:ListLogDeliveries",
                "logs:DescribeExportTasks",
                "logs:GetQueryResults",
                "logs:GetLogEvents",
                "logs:FilterLogEvents",
                "logs:GetLogGroupFields",
                "logs:DescribeResourcePolicies",
                "logs:DescribeDestinations"
            ],
            "Resource": "arn:aws:logs:${var.region}:459088772814:log-group:/ecs/${var.client}-${var.environment}*"
        }
    ]
}
EOF
}

resource "aws_iam_group_policy_attachment" "logs" {
  group      = "Developers-${var.environment}"
  policy_arn = aws_iam_policy.cloudwatch_logs.arn
}
