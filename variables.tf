variable "name_prefix" {
  type = string
  default = "khomma" // change to your name
}

variable "ec2_ssh_key" {
  type = string
  default = "khomma-ssh-rsa" // change to your ssh key
}

variable "aws_vars" {
  type = object({
    vpc_cidr_block = string
    subnet1_name = string
    subnet1_cidr = string
  }
  )
  default = {
    vpc_cidr_block = "192.168.0.0/16"
    subnet1_name = "public"
    subnet1_cidr = "192.168.1.0/24"
  }
}

data http get_myip {
  url = "https://ifconfig.co/ip"
}

locals {
  myip = "${chomp(data.http.get_myip.response_body)}/32"
  ingress_rules = {
    public = [
      {
        cidr_ipv4   = local.myip
        ip_protocol = "tcp"
        from_port   = 22
        to_port     = 22
      },
      {
        cidr_ipv4   = "3.112.23.0/29"
        ip_protocol = "tcp"
        from_port   = 22
        to_port     = 22
      },
      {
        cidr_ipv4   = local.myip
        ip_protocol = "tcp"
        from_port   = 443
        to_port     = 443
      },
      {
        cidr_ipv4   = local.myip
        ip_protocol = "tcp"
        from_port   = 80
        to_port     = 80
      },
      {
        cidr_ipv4   = local.myip
        ip_protocol = "icmp"
        from_port   = -1
        to_port     = -1
      },
      {
        cidr_ipv4   = local.myip
        ip_protocol = "tcp"
        from_port   = 81
        to_port     = 81
      },
    ],
  }
}

variable "ubuntu_info" {
  type = object({
    version = string
    instance_type = string
    disk_sise = number
  }
  )
  default = {
    version = "24.04" // ubuntu version
    instance_type = "t3.small" // instance type
    disk_sise = 60 //GB
  }
}
