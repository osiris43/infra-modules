terraform {
  required_version = ">= 1.2.9"
  backend "s3" {}
}

locals {
  tags               = merge(var.tags, var.default_tags)
  create_sg          = var.default_sg.enabled
  instance_role_name = "${var.name}-instance-role"
  default_sg_name    = "ec2-${var.name}"
  #user_data_rendered = var.user_data_template == "" ? null : templatefile("${var.user_data_template}", { name = var.name })
  security_group_ids = concat(var.vpc_security_group_ids, [data.aws_security_group.mgmt_jumphost.id])
}

resource "aws_instance" "my_instance" {
  depends_on             = [module.default_sg]
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.ssh_key_name
  vpc_security_group_ids = concat(local.security_group_ids, local.create_sg ? ["${module.default_sg[0].security_group.id}"] : [])

  subnet_id = var.subnet_id
  #private_ip            = var.private_ip
  #secondary_private_ips = var.secondary_private_ips

  #iam_instance_profile        = module.instance_profile.instance_profile.name
  #user_data                   = local.user_data_rendered
  #user_data_replace_on_change = var.user_data_replace_on_change
  #associate_public_ip_address = var.associate_public_ip_address

  # root_block_device {
  #   volume_size           = var.root_block_device_volume_size
  #   volume_type           = var.root_block_device_volume_type
  #   encrypted             = var.root_block_device_encrypted
  #   delete_on_termination = var.root_block_device_delete_on_termination
  # }

  # metadata_options {
  #   instance_metadata_tags = var.enable_instance_metadata_tags
  # }

  # lifecycle {
  #   precondition {
  #     condition     = length(var.name) <= 15 || var.override_name_validation
  #     error_message = "NETBIOS is limited to 15 characters. This can be overridden by setting the `override_name_validation`"
  #   }
  # }

  tags = merge(local.tags, {
    "Name" = var.name
  })

}

# module "ebs_volume_attachment" {
#   source = "./ebs"

#   for_each = var.ebs_volume_data

#   name              = each.key
#   instance_id       = aws_instance.my_instance.id
#   availability_zone = var.availability_zone
#   size              = each.value.size
#   type              = each.value.type
#   device_name       = each.value.device_name
#   skip_destroy      = each.value.skip_destroy
#   tags              = local.tags
# }

# module "instance_profile" {
#   source = "./instance_profile"

#   name         = local.instance_role_name
#   iam_policies = var.iam_policies
#   tags         = local.tags
# }

module "default_sg" {
  source = "./default_security_group"

  count = local.create_sg ? 1 : 0

  name                    = local.default_sg_name
  vpc_id                  = var.vpc_id
  allow_ssh_from_cidr     = [var.default_sg.allow_ssh_from_cidr]
  allow_icmp_from_cidr    = [var.default_sg.allow_icmp_from_cidr]
  allow_all_outbound_cidr = [var.default_sg.allow_all_outbound_cidr]

  tags = local.tags
}
