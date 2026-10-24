resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.name_prefix}-vpc"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name_prefix}-igw"
  }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = local.public_subnet_cidr
  availability_zone = local.availability_zones[0]

  tags = {
    Name = "${var.name_prefix}-public"
  }
}

resource "aws_subnet" "private" {
  count = 2

  vpc_id            = aws_vpc.this.id
  cidr_block        = local.private_subnet_cidrs[count.index]
  availability_zone = local.availability_zones[count.index]

  tags = {
    Name = "${var.name_prefix}-private-${count.index + 1}"
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.name_prefix}-nat-eip"
  }
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  depends_on = [aws_internet_gateway.this]

  tags = {
    Name = "${var.name_prefix}-nat"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name_prefix}-public"
  }
}

resource "aws_route" "public_default" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name_prefix}-private"
  }
}

resource "aws_route" "private_default" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
}

resource "aws_route_table_association" "private" {
  count = 2

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private.id]

  tags = {
    Name = "${var.name_prefix}-s3-endpoint"
  }
}

resource "aws_security_group" "workspace" {
  name        = "${var.name_prefix}-workspace"
  description = "Databricks workspace intra-cluster and outbound communication"
  vpc_id      = aws_vpc.this.id

  tags = {
    Name = "${var.name_prefix}-workspace"
  }
}

resource "aws_vpc_security_group_ingress_rule" "self_tcp" {
  security_group_id            = aws_security_group.workspace.id
  referenced_security_group_id = aws_security_group.workspace.id
  ip_protocol                  = "tcp"
  from_port                    = 0
  to_port                      = 65535
}

resource "aws_vpc_security_group_ingress_rule" "self_udp" {
  security_group_id            = aws_security_group.workspace.id
  referenced_security_group_id = aws_security_group.workspace.id
  ip_protocol                  = "udp"
  from_port                    = 0
  to_port                      = 65535
}

resource "aws_vpc_security_group_egress_rule" "all_ipv4" {
  security_group_id = aws_security_group.workspace.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
