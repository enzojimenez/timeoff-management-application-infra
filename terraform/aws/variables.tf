variable "region" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "cluster_nodes" {
  type = number
}

variable "network_preffix" {
  type = string
}

variable "network_suffix" {
  type = string
}

variable "public_subnets" {
  type = map(any)
}

variable "private_subnets" {
  type = map(any)
}

variable "my_ip" {
  type = string
}

variable "runners_ip" {
  type = list(string)
}

variable "ext_dns_name" {
  type = string
}

locals {
  vpc_network = format("%s.%s", var.network_preffix, var.network_suffix)
  tags = {
    Name      = format("eks-%s-cluster", var.cluster_name)
    CreatedBy = "Enzo Jimenez"
  }
}
