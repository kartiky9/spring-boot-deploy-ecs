output "vpc" {
  value = aws_vpc.this.id
}

output "web_rt" {
  value = aws_route_table.web-public-route-table.id
}

output "nat_rt" {
  value = aws_route_table.nat-route-table.*.id
}

output "web_subnet_public" {
  value = aws_subnet.web-public.*.id
}
output "nat_subnet_public" {
  value = aws_subnet.nat-public.*.id
}
output "webhooks_subnet_public" {
  value = aws_subnet.webhooks-public.*.id
}
output "db_subnet_private" {
  value = aws_subnet.db-private.*.id
}
output "db_subnet_group" {
  value = aws_db_subnet_group.this.id
}
