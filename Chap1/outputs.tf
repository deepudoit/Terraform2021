output "s3-bucket" {
  value = aws_s3_bucket.bucket1
}

output "caller" {
  value = data.aws_caller_identity.current
}

output "availability-zones" {
  value = data.aws_availability_zones.azs
}