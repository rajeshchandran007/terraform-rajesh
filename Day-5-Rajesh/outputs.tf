output "ec2_public_ip" {
  value = aws_instance.rc_instance1.public_ip
  
}
output "ssh_command" {
  value = "ssh -i ~/.ssh/id_rsa ubuntu@${aws_instance.rc_instance1.public_ip}"
}
