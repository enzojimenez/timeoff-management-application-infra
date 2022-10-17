resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    endpoint_public_access  = true
    endpoint_private_access = true
    public_access_cidrs = concat(var.runners_ip, [
      var.my_ip
    ])

    security_group_ids = [
      aws_security_group.sg_eks_nodes.id
    ]

    subnet_ids = [
      for subnet in aws_subnet.private_subnets :
      subnet.id
    ]
  }

  kubernetes_network_config {
    ip_family         = "ipv4"
    service_ipv4_cidr = "10.88.99.0/24"
  }

  tags = local.tags

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_subnet.private_subnets
  ]
}

output "endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}
