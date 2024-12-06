output "security_group_web" {
  value = aws_security_group.web.*.id
}
output "security_group_db" {
  value = aws_security_group.db.id
}
output "security_group_ecs" {
  value = aws_security_group.ecs.id
}
