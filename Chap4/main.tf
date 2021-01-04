terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
  required_version = "~> 0.14"
}

provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source             = "terraform-aws-modules/vpc/aws"
  version            = "2.64.0"
  cidr               = var.vpc_cidr
  azs                = data.aws_availability_zones.available.names
  private_subnets    = slice(var.private_subnet_cidr, 0, 2)
  public_subnets     = slice(var.public_subnet_cidr, 0, 2)
  enable_nat_gateway = true
  enable_vpn_gateway = var.enable_vpn_gateway
  tags = var.resource_tags
}

module "app_security_group" {
  source              = "terraform-aws-modules/security-group/aws//modules/web"
  version             = "~> 3.0"
  name                = "web-sg-project-alpha-dev"
  vpc_id              = module.vpc.vpc_id
  description         = "Security group for web-servers with HTTP ports open within VPC"
  ingress_cidr_blocks = module.vpc.public_subnets_cidr_blocks
  tags = var.resource_tags
}

module "lb_security_group" {
  source              = "terraform-aws-modules/security-group/aws//modules/web"
  version             = "~> 3.0"
  name                = "lb-sg-project-alpha-dev"
  vpc_id              = module.vpc.vpc_id
  description         = "Security group for load balancer with HTTP ports open within VPC"
  ingress_cidr_blocks = ["0.0.0.0/0"]
  tags = var.resource_tags
}

resource "random_string" "lb_id" {
  length  = 3
  special = false
}

module "elb_http" {
  source   = "terraform-aws-modules/elb/aws"
  version  = "~> 2.0"
  name     = "lb-${random_string.lb_id.result}-project-alpha-dev"
  internal = false
  security_groups = [module.lb_security_group.this_security_group_id]
  subnets         = module.vpc.public_subnets
  number_of_instances = module.ec2_instance.instance_count
  instances           = module.ec2_instance.id
  listener = [{
    instance_port     = "80"
    instance_protocol = "HTTP"
    lb_port           = "80"
    lb_protocol       = "HTTP"
  }]

  health_check = {
    target              = "HTTP:80/index.html"
    interval            = 10
    healthy_threshold   = 3
    unhealthy_threshold = 10
    timeout             = 5
  }
  tags = var.resource_tags
}

module "ec2_instance" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  version                = "~> 2.0"
  ami                    = "ami-0be2609ba883822ec"
  name                   = "ec2_cluster"
  instance_count         = var.instance_count
  instance_type          = "t2.micro"
  subnet_ids             = module.vpc.private_subnets[*]
  vpc_security_group_ids = [module.app_security_group.this_security_group_id]
  tags = var.resource_tags
}