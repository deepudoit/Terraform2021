terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.20.0"
    }
  }
}

provider "aws" {
  region = var.aws-region
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "2.64.0"
  cidr = var.vpc-cidr-block
  azs = data.aws_availability_zones.available.names
  public_subnets = slice(var.public-subnet-cidr-blocks, 0, 2)
  private_subnets = slice(var.private-subnet-cidr-blocks, 0, 2)
  enable_nat_gateway = false
  enable_vpn_gateway = false
}

module "app-security-group" {
  source = "terraform-aws-modules/security-group/aws//modules/web"
  version = "~> 3.0"
  name = "web-security-group"
  description = "Security group web-servers within VPC"
  vpc_id = module.vpc.vpc_id
  ingress_cidr_blocks = module.vpc.public_subnets_cidr_blocks
}

module "lb-security-group" {
  source = "terraform-aws-modules/security-group/aws//modules/web"
  version = "~> 3.0"
  name = "lb-security-group"
  description = "Security group for load-balancer with HTTP ports within VPC"
  vpc_id = module.vpc.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]
}

resource "random_string" "lb_id" {
  length = 3
  special = false
}

module "ec2-instance" {
  source = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 2.0"
  ami = "ami-0be2609ba883822ec"
  instance_type = var.instance-type
  name = "ec2-instance"
  vpc_security_group_ids = [module.app-security-group.this_security_group_id]
  subnet_ids = module.vpc.private_subnets[*]
  instance_count = var.instance-per-subnet * length(module.vpc.private_subnets)
}

module "elb-http" {
  source = "terraform-aws-modules/elb/aws"
  version = "~> 2.0"
  name = "elb-${random_string.lb_id.result}-project-alpha-dev"
  internal = false
  health_check = {
    target = "HTTP:80/index.html"
    interval = 10
    healthy_threshold = 3
    unhealthy_threshold = 10
    timeout = 5
  }
  listener = [{
    instance_port = "80"
    instance_protocol = "HTTP"
    lb_port = "80"
    lb_protocol = "HTTP"
  }]
//  number_of_instances = module.ec2-instance.instance_count
  instances = module.ec2-instance.id
  security_groups = [module.lb-security-group.this_security_group_id]
  subnets = module.vpc.public_subnets
}

resource "aws_db_subnet_group" "private" {
  subnet_ids = module.vpc.private_subnets
}

resource "aws_db_instance" "db" {
  instance_class = "db.t2.micro"
  allocated_storage = 5
  engine = "mysql"
  username = var.db_username
  password = var.db_password
  db_subnet_group_name = aws_db_subnet_group.private.name
  skip_final_snapshot = true
}