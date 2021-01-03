terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.20.0"
    }
  }

  required_version = "~> 0.14"
}

provider "aws" {
  profile = "default"
  region  = var.region
}

resource "aws_instance" "ec2" {
  ami           = var.ami[var.region]
  instance_type = "t2.micro"
}

resource "aws_eip" "eip" {
  vpc      = true
  instance = aws_instance.ec2.id
}