output "user_pool_id" {
  description = "ID of the Cognito user pool"
  value       = aws_cognito_user_pool.default.id
}

output "user_pool_arn" {
  description = "ARN of the Cognito user pool"
  value       = aws_cognito_user_pool.default.arn
}

output "user_pool_client_id" {
  description = "ID of the Cognito user pool client"
  value       = aws_cognito_user_pool_client.default.id
}

output "user_pool_domain" {
  description = "Full hosted UI domain (e.g. https://your-prefix.auth.us-east-2.amazoncognito.com)"
  value       = "https://${aws_cognito_user_pool_domain.default.domain}.auth.${data.aws_region.current.region}.amazoncognito.com"
}

output "user_pool_endpoint" {
  description = "JWKS endpoint URL for JWT validation (e.g. in Flask)"
  value       = "https://cognito-idp.${data.aws_region.current.region}.amazonaws.com/${aws_cognito_user_pool.default.id}"
}
