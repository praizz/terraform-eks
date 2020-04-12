output "bucket_arn" {
  value       = aws_s3_bucket.remote-state.arn
  description = "`arn` exported from `aws_s3_bucket`"
}

output "bucket_id" {
  value       = aws_s3_bucket.remote-state.id
  description = "`id` exported from `aws_s3_bucket`"
}

output "url" {
  value       = "https://s3-${aws_s3_bucket.remote-state.region}.amazonaws.com/${aws_s3_bucket.remote-state.id}"
  description = "Derived URL to the S3 bucket"
}



