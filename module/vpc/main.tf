
resource "aws_security_group" "alb_sg" {
  name   = "${local.name} GH Runner Security Group"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name} GH Runner Security Group"
  }
}


# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = local.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags =  {
    Name = "${local.name} GH Runner VPC"
  }
}

# Subnets
# Internet Gateway for Public Subnet
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags   = {
    Name = "${local.name} GH Runner Internet Gateway"
  }
}

# EIP for NAT
resource "aws_eip" "nat_eip" {
  domain        = "vpc"
  depends_on = [aws_internet_gateway.internet_gateway]
tags =  {
    Name = "${local.name} GH Runner NAT EIP"
  }

}

# NAT
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.public_subnet.*.id, 0)

  tags = {
    Name = "${local.name} GH Runner Nat Gateway"
  }
}

# Public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(local.public_subnets_cidr_block)
  cidr_block              = element(local.public_subnets_cidr_block, count.index)
  availability_zone       = element(local.availability_zones, count.index)
  map_public_ip_on_launch = true
  tags                    =  {
    Name = "${local.name} GH Runner Public Subnet #${count.index + 1} "
  }
}

# Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(local.private_subnets_cidr_block)
  cidr_block              = element(local.private_subnets_cidr_block, count.index)
  availability_zone       = element(local.availability_zones, count.index)
  map_public_ip_on_launch = false
  tags                    = {
    Name = "${local.name} GH Runner Private Subnet #${count.index + 1}"
  }
}


# Routing tables to route traffic for Private Subnet
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${local.name} GH Runner Private Route Table"
  }
}

# Routing tables to route traffic for Public Subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${local.name} GH Runner Public Route Table"
  }
}

# Route for Internet Gateway
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

# Route for NAT
resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}

# Route table associations for Public Subnets
resource "aws_route_table_association" "public" {
  count          = length(local.public_subnets_cidr_block)
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

# Route table associations for Private Subnets
resource "aws_route_table_association" "private" {
  count          = length(local.private_subnets_cidr_block)
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = aws_route_table.private.id
}
