resource "aws_instance" "web-server" {
  ami           = var.ami_id_value
  instance_type = var.instance_type_value

  tags = {
    Name = var.instance_name_value
  }
}