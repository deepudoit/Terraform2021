variable "region" {
  default     = "us-east-1"
  type        = string
  description = "AWS region"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  default     = "10.0.0.0/16"
  type        = string
}

variable "instance_count" {
  type = number
  description = "Number of Ec2 instances"
  default = 2
}

variable "enable_vpn_gateway" {
  type = bool
  description = "Enable VPN in a VPC"
  default = false
}

variable "public_subnet_cidr" {
  type = list(string)
  description = "List of public subnets"
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
    "10.0.4.0/24",
    "10.0.5.0/24",
    "10.0.6.0/24",
    "10.0.7.0/24",
    "10.0.8.0/24",
  ]
}

variable "private_subnet_cidr" {
  type = list(string)
  description = "List of private subnets"
  default = [
    "10.0.101.0/24",
    "10.0.102.0/24",
    "10.0.103.0/24",
    "10.0.104.0/24",
    "10.0.105.0/24",
    "10.0.106.0/24",
    "10.0.107.0/24",
    "10.0.108.0/24",
  ]
}

variable "resource_tags" {
  type = map(string)
  description = "Tags to set for all resources"
  default = {
    project = "alpha"
    env     = "dev"
  }

  validation {
    condition     = length(var.resource_tags["project"]) <= 16 && length(regexall("/[^a-zA-Z0-9-]/", var.resource_tags["project"])) == 0
    error_message = "The project tag must be no more than 16 characters, and only contain letters, numbers, and hyphens."
  }

  validation {
    condition     = length(var.resource_tags["env"]) <= 8 && length(regexall("/[^a-zA-Z0-9-]/", var.resource_tags["env"])) == 0
    error_message = "The environment tag must be no more than 8 characters, and only contain letters, numbers, and hyphens."
  }
}