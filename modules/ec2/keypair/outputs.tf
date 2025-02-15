output "file" {
  value     = local_file.file
  sensitive = true
}

output "key_name" {
  value = aws_key_pair.my_kp.key_name
}
