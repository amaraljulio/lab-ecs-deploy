resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = var.vpc_tags
}

resource "aws_default_network_acl" "default_network_acl" {
  default_network_acl_id = aws_vpc.vpc.default_network_acl_id
  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  tags = var.vpc_tags
}

resource "aws_default_route_table" "default_route_table" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id
  tags                   = var.vpc_tags
}

resource "aws_default_vpc_dhcp_options" "default_vpc_dhcp_options" {
  tags = var.vpc_tags
}

resource "aws_subnet" "private_subnet" {
  count                           = length(var.private_subnets_cidrs)
  vpc_id                          = aws_vpc.vpc.id
  cidr_block                      = var.private_subnets_cidrs[count.index]
  availability_zone               = var.azs[count.index]
  map_public_ip_on_launch         = false
  assign_ipv6_address_on_creation = false
  tags = merge(
    var.vpc_tags,
    {
      Name = "private-${var.azs[count.index]}"
    }
  )
}

resource "aws_subnet" "public_subnet" {
  count                           = length(var.public_subnets_cidrs)
  vpc_id                          = aws_vpc.vpc.id
  cidr_block                      = var.public_subnets_cidrs[count.index]
  availability_zone               = var.azs[count.index]
  map_public_ip_on_launch         = false
  assign_ipv6_address_on_creation = false
  tags = merge(
    var.vpc_tags,
    {
      Name = "public-${var.azs[count.index]}"
    }
  )
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.public_subnet[0].id
  tags = merge(
    var.vpc_tags,
    {
      Name = "main:nat-gateway"
    }
  )
}

resource "aws_eip" "nat_gateway_eip" {
  vpc = true
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(
    var.vpc_tags,
    {
      Name = "main"
    }
  )
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = merge(
    var.vpc_tags,
    {
      Name = "private:main:route-table"
    }
  )
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = merge(
    var.vpc_tags,
    {
      Name = "public:main:route-table"
    }
  )
}

resource "aws_route_table_association" "private_route_table_association" {
  count          = length(var.private_subnets_cidrs)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "public_route_table_association" {
  count          = length(var.public_subnets_cidrs)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_vpc_endpoint" "s3_vpc_endpoint" {
  vpc_id       = aws_vpc.vpc.id
  service_name = "com.amazonaws.${var.aws_region}.s3"
  auto_accept  = true
}
