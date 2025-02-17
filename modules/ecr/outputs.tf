output "ecr_arn" {
  value = aws_ecr_repository.my_repo.arn
}

output "ecr_repository_url" {
  value = aws_ecr_repository.my_repo.repository_url
}

output "ecr_name" {
  value = aws_ecr_repository.my_repo.name
}
