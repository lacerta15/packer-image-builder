packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "aws_region"     { default = "ap-southeast-1" }
variable "instance_type"  { default = "t3.medium" }

source "amazon-ebs" "rhel9" {
  ami_name      = "rhel9-golden-{{timestamp}}"
  ami_description = "RHEL 9 hardened golden image"
  instance_type = var.instance_type
  region        = var.aws_region

  source_ami_filter {
    filters = {
      name                = "RHEL-9*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["309956199498"]
    most_recent = true
  }

  ssh_username = "ec2-user"
  tags = {
    Name        = "RHEL9 Golden Image"
    OS          = "RHEL 9"
    BuildDate   = "{{timestamp}}"
    ManagedBy   = "Packer"
  }
}

build {
  sources = ["source.amazon-ebs.rhel9"]

  provisioner "shell" {
    script = "scripts/harden.sh"
  }

  provisioner "ansible" {
    playbook_file = "ansible/baseline.yml"
  }

  post-processor "manifest" {
    output = "manifest.json"
  }
}
