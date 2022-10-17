resource "aws_route53_zone" "eks_route53_zone" {
  name = format("%s.%s", var.cluster_name, var.ext_dns_name)
  tags = local.tags
}

output "name_servers" {
  description = "Name Servers"
  value       = aws_route53_zone.eks_route53_zone.name_servers
}
