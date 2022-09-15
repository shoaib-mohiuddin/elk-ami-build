packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "ami_prefix" {
  type    = string
  default = "ami"
}
variable "instance_type" {
  type    = string
  default = "t3.medium"
}
variable "region" {
  type    = string
  default = "us-west-2"
}
variable "vpc_id" {
  type    = string
  default = "vpc-0d52f3b7589ef1580"
}
variable "subnet_id" {
  type    = string
  default = "subnet-08c04b43218b0304d"
}
variable "security_group_id" {
  type    = string
  default = "sg-06e29a5926273035a"
}

variable "stack_e" {
  type    = string
  default = "elasticsearch"
}

variable "stack_l" {
  type    = string
  default = "logstash"
}

variable "stack_k" {
  type    = string
  default = "kibana"
}

variable "stack_f" {
  type    = string
  default = "filebeat"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}


source "amazon-ebs" "elasticsearch" {
  ami_name                    = "${var.ami_prefix}-${var.stack_e}"
  instance_type               = var.instance_type
  region                      = var.region
  vpc_id                      = var.vpc_id
  subnet_id                   = var.subnet_id
  security_group_id           = var.security_group_id
  associate_public_ip_address = true
  force_deregister            = true
  force_delete_snapshot       = true
  deprecate_at                = timeadd(timestamp(), "8760h")

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  tags = {
    Name    = "ami-elasticsearch"
    BaseAMI = "{{ .SourceAMIName }}"
  }
  ssh_username = "ubuntu"
}

build {
  name = "packer-elasticsearch"
  sources = [
    "source.amazon-ebs.elasticsearch"
  ]
  provisioner "ansible" {
    playbook_file   = "./playbooks/elk_stack.yml"
    extra_arguments = ["--extra-vars", "stack=${var.stack_e}"]
  }

}

source "amazon-ebs" "logstash" {
  ami_name                    = "${var.ami_prefix}-${var.stack_l}"
  instance_type               = var.instance_type
  region                      = var.region
  vpc_id                      = var.vpc_id
  subnet_id                   = var.subnet_id
  security_group_id           = var.security_group_id
  associate_public_ip_address = true
  force_deregister            = true
  force_delete_snapshot       = true
  deprecate_at                = timeadd(timestamp(), "8760h")

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  tags = {
    Name    = "ami-logstash"
    BaseAMI = "{{ .SourceAMIName }}"
  }
  ssh_username = "ubuntu"
}

build {
  name = "packer-logstash"
  sources = [
    "source.amazon-ebs.logstash"
  ]
  provisioner "ansible" {
    playbook_file   = "./playbooks/elk_stack.yml"
    extra_arguments = ["--extra-vars", "stack=${var.stack_l}"]
  }

}

source "amazon-ebs" "kibana" {
  ami_name                    = "${var.ami_prefix}-${var.stack_k}"
  instance_type               = var.instance_type
  region                      = var.region
  vpc_id                      = var.vpc_id
  subnet_id                   = var.subnet_id
  security_group_id           = var.security_group_id
  associate_public_ip_address = true
  force_deregister            = true
  force_delete_snapshot       = true
  deprecate_at                = timeadd(timestamp(), "8760h")

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  tags = {
    Name    = "ami-kibana"
    BaseAMI = "{{ .SourceAMIName }}"
  }
  ssh_username = "ubuntu"
}

build {
  name = "packer-kibana"
  sources = [
    "source.amazon-ebs.kibana"
  ]
  provisioner "ansible" {
    playbook_file   = "./playbooks/elk_stack.yml"
    extra_arguments = ["--extra-vars", "stack=${var.stack_k}"]
  }

}

source "amazon-ebs" "filebeat" {
  ami_name                    = "${var.ami_prefix}-${var.stack_f}"
  instance_type               = var.instance_type
  region                      = var.region
  vpc_id                      = var.vpc_id
  subnet_id                   = var.subnet_id
  security_group_id           = var.security_group_id
  associate_public_ip_address = true
  force_deregister            = true
  force_delete_snapshot       = true
  deprecate_at                = timeadd(timestamp(), "8760h")

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  tags = {
    Name    = "ami-filebeat"
    BaseAMI = "{{ .SourceAMIName }}"
  }
  ssh_username = "ubuntu"
}

build {
  name = "packer-filebeat"
  sources = [
    "source.amazon-ebs.filebeat"
  ]
  provisioner "ansible" {
    #playbook_file   = "./playbooks/filebeat.yml"
    playbook_file   = "./playbooks/elk_stack.yml"
    extra_arguments = ["--extra-vars", "stack=${var.stack_f}"]
  }

}