terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.23.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 1.2"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.1"
    }
  }
  required_version = ">= 0.14"
}

provider "aws" {
  region = local.region
}
