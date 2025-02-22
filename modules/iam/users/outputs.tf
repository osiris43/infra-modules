output "user_arn" {
  value = aws_iam_user.user.arn
}

output "user_name" {
  value = aws_iam_user.user.name
}

output "user_id" {
  value = aws_iam_user.user.unique_id
}

output "policy_attachment_arn" {
  value = aws_iam_user_policy_attachment.policy_attach.*.policy_arn
}

output "credentials" {
  value = {
    "ACCESS_KEY_ID"     = aws_iam_access_key.user_access_key.id
    "SECRET_ACCESS_KEY" = aws_iam_access_key.user_access_key.secret
    "CONSOLE_PASSWORD"  = var.user.enable_console_access ? data.pgp_decrypt.user_password_decrypt[0].plaintext : "n/a"
  }
  sensitive = true
}

output "signin_url" {
  value = "https://${var.aws_account_id}.signin.aws.amazon.com/console"
}
