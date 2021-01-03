terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">=3.20.0"
    }
  }
  required_version = "~> 0.14"
}

provider "aws" {
  region = "us-east-1"
}