output "hw_cloudfront" {
  description = "The domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.hw_cloudfront
}