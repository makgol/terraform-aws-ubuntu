variable "ssh_key" {
  type = string
}

variable "vm_name" {
  type = string
}

variable "sg_ids" {
  type = list(string)
}

variable "subnet_id" {
  type = string
}

variable "ubuntu_info" {
  type = object({
    version = string
    instance_type = string
    disk_sise = number
  })
}  

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/*/ubuntu-*-${var.ubuntu_info.version}-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_instance" "ubuntu" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.ubuntu_info.instance_type
  subnet_id     = var.subnet_id
  key_name = var.ssh_key
  vpc_security_group_ids = var.sg_ids
  tags = {
    Name = var.vm_name
  }
  user_data = file("./templates/ubuntu/userdata")
  root_block_device {
    volume_size = var.ubuntu_info.disk_sise
  }
}

resource "aws_eip" "ubuntu" {
  instance = aws_instance.ubuntu.id
  domain   = "vpc"
  tags = {
    Name = replace("${var.vm_name}", "_ubuntu_", "_ubuntu-eip_")
  }
}

resource "aws_ec2_instance_state" "ubuntu" {
  instance_id = aws_instance.ubuntu.id
  state       = "running"
}

