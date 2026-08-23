output "s3_bucket_arn" {
  description = "The ARN of the s3 bucket"
  value       = aws_s3_bucket.bucket.arn
}

output "s3_bucket_id" {
  description = "The name of the bucket"
  value       = aws_s3_bucket.bucket.id
}

output "s3_bucket_regional_domain_name" {
  description = "Regional domain name of the bucket, e.g. for building object URLs"
  value       = aws_s3_bucket.bucket.bucket_regional_domain_name
}
