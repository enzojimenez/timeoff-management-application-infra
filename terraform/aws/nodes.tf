resource "aws_eks_node_group" "eks_node_group" {
  cluster_name           = aws_eks_cluster.eks_cluster.name
  node_group_name_prefix = format("%s-nodes", local.tags.Name)
  node_role_arn          = aws_iam_role.eks_role.arn
  subnet_ids = [
    for subnet in aws_subnet.private_subnets :
    subnet.id
  ]

  tags = local.tags

  scaling_config {
    desired_size = var.cluster_nodes
    max_size     = 4
    min_size     = 2
  }

  update_config {
    max_unavailable = 1
  }

  timeouts {
    create = "15m"
  }

  depends_on = [
    aws_eks_cluster.eks_cluster,
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_subnet.private_subnets,
    aws_subnet.public_subnets,
    aws_route_table.private_route_table
  ]
}

resource "aws_autoscaling_group_tag" "eks_group_tag" {
  autoscaling_group_name = aws_eks_node_group.eks_node_group.resources[0].autoscaling_groups[0].name

  tag {
    key                 = "Name"
    value               = format("%s-nodes", local.tags.Name)
    propagate_at_launch = true
  }

  depends_on = [
    aws_eks_node_group.eks_node_group
  ]
}
