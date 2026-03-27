output "arn" {
  description = "ARN of the Lightsail container service"
  value       = aws_lightsail_container_service.default.arn
}

output "url" {
  description = "Public URL of the Lightsail container service"
  value       = aws_lightsail_container_service.default.url
}

output "name" {
  description = "Name of the Lightsail container service"
  value       = aws_lightsail_container_service.default.name
}

output "ecr_principal_arn" {
  description = "IAM principal ARN used by the container service to pull from ECR"
  value       = aws_lightsail_container_service.default.private_registry_access[0].ecr_image_puller_role[0].principal_arn
}
