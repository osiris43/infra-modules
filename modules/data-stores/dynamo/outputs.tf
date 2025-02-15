output "arn" {
  value = aws_dynamodb_table.table.arn
}

output "billing_mode" {
  value = aws_dynamodb_table.table.billing_mode
}

output "hash_key" {
  value = aws_dynamodb_table.table.hash_key
}

output "id" {
  value = aws_dynamodb_table.table.id
}

output "name" {
  value = aws_dynamodb_table.table.name
}

output "range_key" {
  value = aws_dynamodb_table.table.range_key
}
