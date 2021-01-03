
//S3 bucket resource
resource "aws_s3_bucket" "bucket1" {
  bucket = "pgandla-tf-bkt"
  acl = "private"
  tags = {
    Name = "tf bucket"
    Env = "dev"
  }
}

//S3 bucket
resource "aws_s3_bucket" "bucket2" {
  bucket = "pgandla-${data.aws_caller_identity.current.account_id}"
}

data "aws_caller_identity" "current" {}

data "aws_availability_zones" "azs" {
  state = "available"
}

