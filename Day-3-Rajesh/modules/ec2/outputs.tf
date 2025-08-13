output "name" {
    value = aws_instance.web-server.tags["Name"]
}
output "public_ip" {
    value = aws_instance.web-server.public_ip
}
output "private_ip" {
    value = aws_instance.web-server.private_ip
}
    