output "webhooks_url" {
  value = aws_route53_record.ecs_webhooks_lb.fqdn
}
output "lb_arn_suffix" {
  value = aws_lb.web.arn_suffix
}
output "tg_arn_suffix" {
  value = aws_lb_target_group.web_app.arn_suffix
}
