resource "aws_vpc" "eks_vpc" {
  cidr_block           = local.vpc_network
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = local.tags
}

resource "aws_subnet" "private_subnets" {
  for_each                = var.private_subnets
  vpc_id                  = aws_vpc.eks_vpc.id
  availability_zone       = format("%s%s", var.region, each.key)
  cidr_block              = format("%s.%s", var.network_preffix, each.value)
  map_public_ip_on_launch = false
  tags = merge(local.tags, {
    Name                                                     = format("%s-%s-private", local.tags.Name, format("%s%s", var.region, each.key)),
    format("kubernetes.io/cluster/%s", var.cluster_name) = "shared",
    "kubernetes.io/role/elb"                                 = "1"
  })
  depends_on = [
    aws_vpc.eks_vpc
  ]
}


resource "aws_subnet" "public_subnets" {
  for_each                = var.public_subnets
  vpc_id                  = aws_vpc.eks_vpc.id
  availability_zone       = format("%s%s", var.region, each.key)
  cidr_block              = format("%s.%s", var.network_preffix, each.value)
  map_public_ip_on_launch = true
  tags = merge(local.tags, {
    Name                                                     = format("%s-%s-public", local.tags.Name, format("%s%s", var.region, each.key)),
    format("kubernetes.io/cluster/%s", var.cluster_name) = "shared",
    "kubernetes.io/role/elb"                                 = "1"
  })
  depends_on = [
    aws_vpc.eks_vpc
  ]
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.eks_vpc.id
  tags   = local.tags
  depends_on = [
    aws_vpc.eks_vpc
  ]
}

resource "aws_eip" "e_ip" {
  vpc  = true
  tags = local.tags
  depends_on = [
    aws_internet_gateway.gw
  ]
}

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.e_ip.id
  subnet_id     = aws_subnet.public_subnets["a"].id
  tags          = local.tags
  depends_on = [
    aws_subnet.public_subnets,
    aws_internet_gateway.gw,
    aws_eip.e_ip
  ]
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw.id
  }

  tags = merge(local.tags, {
    Name = format("%s-private", local.tags.Name)
  })

  depends_on = [
    aws_nat_gateway.natgw
  ]
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = merge(local.tags, {
    Name = format("%s-public", local.tags.Name)
  })

  depends_on = [
    aws_internet_gateway.gw
  ]
}

resource "aws_route_table_association" "private_route_assoc" {
  for_each       = var.private_subnets
  subnet_id      = aws_subnet.private_subnets[each.key].id
  route_table_id = aws_route_table.private_route_table.id
  depends_on = [
    aws_subnet.private_subnets
  ]
}

resource "aws_route_table_association" "public_route_assoc" {
  for_each       = var.public_subnets
  subnet_id      = aws_subnet.public_subnets[each.key].id
  route_table_id = aws_route_table.public_route_table.id
  depends_on = [
    aws_subnet.public_subnets
  ]
}

output "e_public_ip" {
  description = "Elastic Public IP"
  value       = aws_eip.e_ip.public_ip
}
