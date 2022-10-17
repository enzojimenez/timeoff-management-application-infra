terraform {
  required_version = ">= 0.13.1"
  backend "s3" {
    bucket = "gorilla-devops-eng-tf"
    key    = "cloudflare/terraform.tfstate"
    region = "us-east-1"
  }
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = ">= 3.0"
    }
  }
}
