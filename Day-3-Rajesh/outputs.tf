output "name" {
    value = module.ec2_module.name
}
output "public_ip" {
    value = module.ec2_module.public_ip
}
output "private_ip" {
    value = module.ec2_module.private_ip
}