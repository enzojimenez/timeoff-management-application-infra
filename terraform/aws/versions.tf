terraform {
  required_version = ">= 0.13.1"
  backend "s3" {
    bucket = "gorilla-devops-eng-tf"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"
  }
  required_providers {
    aws        = ">= 4.34.0"
    kubernetes = ">= 1.11"
  }
}
