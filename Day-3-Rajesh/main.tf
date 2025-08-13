module "ec2_module" {
    source = "./modules/ec2"
    instance_type_value = var.instance_type_value
    ami_id_value        = var.ami_id_value
    instance_name_value = var.instance_name_value
}