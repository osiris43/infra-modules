output "instance_id" {
  value = aws_instance.my_instance.id
}

output "public_dns" {
  value = aws_instance.my_instance.public_dns
}

output "public_ip" {
  value = aws_instance.my_instance.public_ip
}

output "private_ip" {
  value = aws_instance.my_instance.private_ip
}

output "security_group_id" {
  value = local.create_sg ? module.default_sg[0].security_group.id : null
}

output "security_group_name" {
  value = local.create_sg ? module.default_sg[0].security_group.name : null
}

output "subnet_id" {
  value = aws_instance.my_instance.subnet_id
}

output "vpc_id" {
  value = var.vpc_id
}


output "ebs_volume_data" {
  value = module.ebs_volume_attachment
}

output "instance_access_profile_arn" {
  value = module.instance_profile.instance_profile.arn
}

output "instance_access_profile_name" {
  value = module.instance_profile.instance_profile.name
}

output "instance_arn" {
  value = aws_instance.my_instance.arn
}
