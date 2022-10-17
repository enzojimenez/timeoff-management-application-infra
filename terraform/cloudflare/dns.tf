data "cloudflare_zone" "cf_zone" {
  name = var.ext_dns_name
}

data "aws_route53_zone" "eks_route53_zone" {
  name = format("%s.%s", var.cluster_name, var.ext_dns_name)
}

resource "cloudflare_record" "cf_record" {
  for_each = toset(data.aws_route53_zone.eks_route53_zone.name_servers)
  zone_id  = data.cloudflare_zone.cf_zone.id
  name     = var.cluster_name
  value    = each.key
  type     = "NS"
  ttl      = "120"
}
