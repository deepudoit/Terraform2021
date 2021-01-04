variable "aws-region" {
  type = string
  description = "AWS Region"
  default = "us-east-1"
}

variable "vpc-cidr-block" {
  description = "CIDR block for VPC"
  type = string
  default = "10.0.0.0/16"
}

variable "public-subnet-cidr-blocks" {
  description = "Public subnet cidr blocks"
  type = list(string)
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
    "10.0.4.0/24",
    "10.0.5.0/24",
    "10.0.6.0/24",
    "10.0.7.0/24",
    "10.0.8.0/24"
  ]
}

variable "private-subnet-cidr-blocks" {
  description = "Private subnets cidr clocks"
  type = list(string)
  default = [
    "10.0.101.0/24",
    "10.0.102.0/24",
    "10.0.103.0/24",
    "10.0.104.0/24",
    "10.0.105.0/24",
    "10.0.106.0/24",
    "10.0.107.0/24",
    "10.0.108.0/24"
  ]
}

variable "instance-per-subnet" {
  description = "Number of instance per subnet"
  type = number
  default = 1
}

variable "instance-type" {
  description = "Ec2 instance type"
  type = string
  default = "t2.micro"
}

variable "db_username" {
  description = "database admin username"
  type = string
  sensitive = true
}

variable "db_password" {
  description = "database admin password"
  type = string
  sensitive = true
}