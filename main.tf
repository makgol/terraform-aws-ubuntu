resource "random_id" "suffix_id" {
  byte_length = 4
}

locals {
  name_suffix = random_id.suffix_id.id
}

resource "aws_vpc" "vpc" {
  cidr_block = var.aws_vars.vpc_cidr_block
  tags = {
    Name = "${var.name_prefix}_vpc_${local.name_suffix}"
  }
}

resource "aws_subnet" "subnet1" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.aws_vars.subnet1_cidr
  tags = {
    Name = "${var.name_prefix}_${var.aws_vars.subnet1_name}_${local.name_suffix}"
  }
}

resource "aws_internet_gateway" "inet_gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.name_prefix}_internet-gw_${local.name_suffix}"
  }
}

resource "aws_route_table" "subnet1_default_route" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.inet_gw.id
  }

  tags = {
    Name = "${var.name_prefix}_default-route_${local.name_suffix}"
  }
}

resource "aws_route_table_association" "subnet1_route" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.subnet1_default_route.id
}

module "security_groups" {
  for_each = local.ingress_rules

  source = "./modules/aws_security_groups/"
  rules = each.value
  sg_name = "${var.name_prefix}_sg-${each.key}_${local.name_suffix}"
  vpc_id = aws_vpc.vpc.id
}

module "ubuntu_vm" {
  source = "./modules/aws_ubuntu/"
  subnet_id = aws_subnet.subnet1.id
  sg_ids = [lookup(module.security_groups["public"].sg_ids, "sg_id", null)]
  ssh_key = var.ec2_ssh_key
  vm_name = "${var.name_prefix}_ubuntu_${local.name_suffix}"
  ubuntu_info = var.ubuntu_info
}
