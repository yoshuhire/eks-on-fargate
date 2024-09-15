#############
# VPC & Subnet
#############
resource "aws_vpc" "this" {
  cidr_block = var.vpc_config.cidr_block

  enable_dns_support   = var.vpc_config.enable_dns_support
  enable_dns_hostnames = var.vpc_config.enable_dns_hostnames

  tags = {
    Name = "vpc-eks-cluster-${var.env}"
  }
}

resource "aws_subnet" "private" {
  for_each = { for subnet in var.subnet_config.private : subnet.availability_zone => subnet }

  vpc_id            = aws_vpc.this.id
  availability_zone = each.value.availability_zone
  cidr_block        = each.value.cidr_block

  tags = {
    Name = "subnet-private-eks-cluster-${var.env}-${each.value.availability_zone}"
    # KCCM と ALBC のサブネット識別用タグ(Private)
    "kubernetes.io/cluster/eks-cluster-${var.env}" = "shared"
    "kubernetes.io/role/internal-elb"              = 1
  }
}

resource "aws_subnet" "public" {
  for_each = { for subnet in var.subnet_config.public : subnet.availability_zone => subnet }

  vpc_id            = aws_vpc.this.id
  availability_zone = each.value.availability_zone
  cidr_block        = each.value.cidr_block

  tags = {
    Name = "subnet-public-eks-cluster-${var.env}-${each.value.availability_zone}"
    # KCCM と ALBC のサブネット識別用タグ(Public)
    "kubernetes.io/cluster/eks-cluster-${var.env}" = "shared"
    "kubernetes.io/role/elb"                       = 1
  }
}

#############
# IGW
#############
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "igw-vpc-eks-cluster-${var.env}"
  }
}

#############
# Route Table
#############

## Private
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "rtb-subnet-private-eks-cluster-${var.env}"
  }
}

resource "aws_route_table_association" "private" {
  for_each = { for subnet in var.subnet_config.private : subnet.availability_zone => subnet }

  subnet_id      = aws_subnet.private[each.value.availability_zone].id
  route_table_id = aws_route_table.private.id
}

## Public
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "rtb-subnet-public-eks-cluster-${var.env}"
  }
}

resource "aws_route_table_association" "public" {
  for_each = { for subnet in var.subnet_config.public : subnet.availability_zone => subnet }

  subnet_id      = aws_subnet.public[each.value.availability_zone].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route" "public_to_igw" {
  route_table_id = aws_route_table.public.id

  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

#############
# Security Group
#############

## ALB
resource "aws_security_group" "alb" {
  name        = "nsg-eks-alb-${var.env}"
  vpc_id      = aws_vpc.this.id
  description = "SG for ALB"

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = var.accessible_ip_list.to_web_server
  }

  tags = {
    Name = "nsg-eks-alb-${var.env}"
  }
}

## VPCE
resource "aws_security_group" "vpce" {
  name        = "nsg-eks-vpce-${var.env}"
  vpc_id      = aws_vpc.this.id
  description = "SG for VPCE"

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [var.vpc_config.cidr_block]
  }

  tags = {
    Name = "nsg-eks-vpce-${var.env}"
  }
}

## EKS Cluster
resource "aws_security_group" "eks_cluster" {
  name        = "nsg-eks-cluster-${var.env}"
  vpc_id      = aws_vpc.this.id
  description = "SG for EKS Cluster"

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name                                           = "nsg-eks-cluster-${var.env}"
    "kubernetes.io/cluster/eks-cluster-${var.env}" = "owned"
  }
}

#############
# VPCE
#############
resource "aws_vpc_endpoint" "this" {
  for_each = { for vpce in var.vpce_config : vpce.usage => vpce }

  vpc_id              = aws_vpc.this.id
  service_name        = each.value.service_name
  vpc_endpoint_type   = each.value.vpc_endpoint_type
  route_table_ids     = each.value.vpc_endpoint_type == "Gateway" ? [aws_route_table.private.id] : []
  subnet_ids          = each.value.vpc_endpoint_type == "Interface" ? [for subnet in aws_subnet.private : subnet.id] : []
  security_group_ids  = each.value.vpc_endpoint_type == "Interface" ? [aws_security_group.vpce.id] : []
  private_dns_enabled = each.value.vpc_endpoint_type == "Interface" ? true : false

  tags = {
    Name = "vpce-${each.value.usage}-${var.env}"
  }
}