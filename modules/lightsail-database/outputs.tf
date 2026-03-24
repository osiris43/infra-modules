output "arn" {
  description = "ARN of the Lightsail database"
  value       = aws_lightsail_database.default.arn
}

output "id" {
  description = "ID of the Lightsail database"
  value       = aws_lightsail_database.default.id
}

output "master_endpoint_address" {
  description = "Hostname of the database endpoint"
  value       = aws_lightsail_database.default.master_endpoint_address
}

output "master_endpoint_port" {
  description = "Port of the database endpoint"
  value       = aws_lightsail_database.default.master_endpoint_port
}

output "master_database_name" {
  description = "Name of the initial database"
  value       = aws_lightsail_database.default.master_database_name
}

output "master_username" {
  description = "Master username for the database"
  value       = aws_lightsail_database.default.master_username
}
