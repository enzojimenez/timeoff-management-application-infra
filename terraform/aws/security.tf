resource "aws_security_group" "sg_eks_nodes" {
  name        = format("%s-nodes", local.tags.Name)
  description = "Allow traffic from/to EKS Worker Nodes"
  vpc_id      = aws_vpc.eks_vpc.id

  ingress {
    description = "VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [local.vpc_network]
  }

  ingress {
    description = "SG-self"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}
