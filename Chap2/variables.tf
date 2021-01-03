variable "region" {
  default = "us-east-1"
}

variable "ami" {
  type = map(string)
  default = {
    "us-east-1" = "ami-053adf54573f777cf"
    "us-west-2" = "ami-0cc158853935719b7"
  }
}