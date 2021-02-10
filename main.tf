variable "pub_key" {
  type        = string
  description = "the public key that will be added to all 3 machines for SSH."
}

locals {
  target_count              = 2
  vpc_cidr                  = "192.168.0.0/16"                 # all VPCs have the same range
  vm_cidr                   = cidrsubnet(local.vpc_cidr, 8, 0) # all vms are in the same range
  vpc_endpoints_cidr        = cidrsubnet(local.vpc_cidr, 8, 1) # all vpc_endpoint related resources are in the same range. 
  region                    = "eu-west-1"                      # all the resources must be in the same region for this to work
  vpc_endpoint_supported_az = "eu-west-1a"                     # the single az supported by vpc_endpoints in eu-west-1
  other_azs                 = ["eu-west-1b", "eu-west-1c"]
  ssh_port                  = 22
}

data "aws_ami" "this" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

output "monitoring_public_ip" {
  value = aws_instance.monitoring.public_ip
}

output "target_0" {
  value = aws_vpc_endpoint.target[0].dns_entry
}

output "target_1" {
  value = aws_vpc_endpoint.target[1].dns_entry
}

output "target_private_ips" {
  value = aws_instance.target.*.private_ip

}
