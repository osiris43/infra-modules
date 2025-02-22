output "policy_arn" {
  description = "The ARN of the IAM Policy"
  value       = module.policy.policy.arn
}
