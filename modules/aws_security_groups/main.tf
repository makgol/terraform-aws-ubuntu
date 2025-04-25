variable "rules" {
  type = list(object({
    cidr_ipv4   = string
    ip_protocol = string
    from_port   = number
    to_port     = number
  }))
}

variable "sg_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

resource "aws_security_group" "security_group" {
  name        = var.sg_name
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.sg_name}"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ingress_rule" {
  for_each = { for i, rule in var.rules : "${rule.cidr_ipv4}-${rule.ip_protocol}-${rule.from_port}-${rule.to_port}" => rule }

  security_group_id = aws_security_group.security_group.id
  cidr_ipv4         = each.value.cidr_ipv4
  ip_protocol       = each.value.ip_protocol
  from_port         = each.value.from_port
  to_port           = each.value.to_port
}

resource "aws_vpc_security_group_egress_rule" "egress_rule" {
  security_group_id = aws_security_group.security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = -1
  from_port         = -1
  to_port           = -1
}
