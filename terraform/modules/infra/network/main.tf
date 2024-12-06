resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
  tags = {
    description = "VPC ${var.client}-${var.environment}"
    Name        = "${var.client}-${var.environment}-vpc"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "web-public" {
  count                   = length(var.subnet_web_public)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.subnet_web_public[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.client}-${var.environment}-web-public-subnet${count.index + 1}"
  }
}

resource "aws_subnet" "db-private" {
  count                   = length(var.subnet_db_private)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.subnet_db_private[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.client}-${var.environment}-db-private-subnet${count.index + 1}"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    description = "Internet Gateway"
    Name        = "${var.client}-${var.environment}-ig"
  }
}

# One public route table
resource "aws_route_table" "web-public-route-table" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.client}-${var.environment}-public-rt"
  }
}

resource "aws_route" "IGW" {
  route_table_id         = aws_route_table.web-public-route-table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "web-public" {
  count = length(var.subnet_web_public)

  subnet_id      = aws_subnet.web-public[count.index].id
  route_table_id = aws_route_table.web-public-route-table.id
}

# Private route table
resource "aws_route_table" "db-private-route-table" {
  count = length(var.subnet_db_private)

  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.client}-${var.environment}-db-private-rt-${count.index + 1}"
  }
}

resource "aws_route_table_association" "db-private" {
  count          = length(var.subnet_db_private)
  subnet_id      = aws_subnet.db-private[count.index].id
  route_table_id = aws_route_table.db-private-route-table[count.index].id
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.client}-${var.environment}-db-sbg"
  subnet_ids = aws_subnet.db-private.*.id
  tags = {
    Name = "${var.client}-${var.environment}-db-sbg"
  }
}

# # NAT
# resource "aws_subnet" "nat-public" {
#   count                   = length(var.subnets_nat_public)
#   vpc_id                  = aws_vpc.this.id
#   cidr_block              = var.subnets_nat_public[count.index]
#   availability_zone       = data.aws_availability_zones.available.names[count.index]
#   map_public_ip_on_launch = false
#   tags = {
#     Name = "${var.client}-${var.environment}-nat-subnet${count.index + 1}"
#   }
# }

# resource "aws_eip" "nat_gw" {
#   count = length(aws_subnet.nat-public)

#   vpc = true
#   tags = {
#     Name = "${var.client}-${var.environment}-nat-EIP-${count.index + 1}"
#   }

# }

# resource "aws_nat_gateway" "this" {
#   count = length(aws_subnet.nat-public)

#   allocation_id = element(aws_eip.nat_gw.*.id, count.index)
#   subnet_id     = aws_subnet.nat-public[count.index].id

#   tags = {
#     Name = "${var.client}-${var.environment}-nat-gw-${count.index + 1}"
#   }
# }

# resource "aws_route_table" "nat-route-table" {
#   vpc_id = aws_vpc.this.id

#   tags = {
#     Name = "${var.client}-${var.environment}-nat-public-rt"
#   }
# }

# resource "aws_route" "nat-public" {
#   route_table_id         = aws_route_table.nat-route-table.id
#   destination_cidr_block = "0.0.0.0/0"
#   gateway_id             = aws_internet_gateway.this.id
# }

# resource "aws_route_table_association" "nat-public" {
#   count = length(var.subnets_nat_public)

#   subnet_id      = aws_subnet.nat-public[count.index].id
#   route_table_id = aws_route_table.nat-route-table.id
# }

# resource "aws_route" "nat" {
#   count = length(var.subnet_db_private) * (length(var.subnets_nat_public) > 0 ? 1 : 0)

#   destination_cidr_block = "0.0.0.0/0"
#   route_table_id         = aws_route_table.db-private-route-table[count.index].id
#   nat_gateway_id         = aws_nat_gateway.this[count.index % length(var.subnets_nat_public)].id
# }

# resource "aws_route" "peering" {
#   count = length(var.subnet_db_private) * (length(var.subnets_nat_public) > 0 ? 1 : 0)

#   route_table_id            = aws_route_table.db-private-route-table[count.index].id
#   destination_cidr_block    = data.aws_vpc_peering_connection.datascience_peering[0].cidr_block
#   vpc_peering_connection_id = data.aws_vpc_peering_connection.datascience_peering[0].id
# }
