output "lightsail_arn" {
  description = "ARN that identifies the Lightsail instance"
  value       = aws_lightsail_container_service.default.arn
}

output "lightsail_url" {
  description = "URL that identifies the Lightsail instance"
  value       = aws_lightsail_container_service.default.url
}

