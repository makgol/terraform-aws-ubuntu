output "sg_ids" {
  value = {
    subnet_name = var.sg_name
    sg_id = aws_security_group.security_group.id
  }
}