output "policy_arn" {
  description = "The ARN of the IAM Policy"
  value       = aws_iam_policy.this.policy.arn
}
