# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------
variable "app_name" {
  description = "Application name used for naming and tagging resources"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g. prod, staging, dev)"
  type        = string
}

variable "domain_prefix" {
  description = "Cognito hosted UI subdomain prefix (e.g. your-app-auth)"
  type        = string
}

variable "callback_urls" {
  description = "List of allowed OAuth callback URLs (e.g. http://localhost:3000/callback, https://yourapp.com/callback)"
  type        = list(string)
}

variable "logout_urls" {
  description = "List of allowed logout redirect URLs"
  type        = list(string)
}

variable "google_client_id" {
  description = "Google OAuth client ID"
  type        = string
  sensitive   = true
}

variable "google_client_secret" {
  description = "Google OAuth client secret"
  type        = string
  sensitive   = true
}

variable "facebook_app_id" {
  description = "Facebook app ID"
  type        = string
  sensitive   = true
}

variable "facebook_app_secret" {
  description = "Facebook app secret"
  type        = string
  sensitive   = true
}

variable "apple_services_id" {
  description = "Apple services ID (the identifier registered for Sign In with Apple)"
  type        = string
  sensitive   = true
}

variable "apple_team_id" {
  description = "Apple developer team ID"
  type        = string
  sensitive   = true
}

variable "apple_key_id" {
  description = "Apple private key ID"
  type        = string
  sensitive   = true
}

variable "apple_private_key" {
  description = "Full contents of the Apple .p8 private key file"
  type        = string
  sensitive   = true
}
