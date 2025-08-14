# MIGRATION TO TERRAFORM & DRIFT DETECTION

https://youtu.be/-4IMy5ihiiU

## Terraform import commands

**Write the import code block inside the tf file**

```
import {
    id = "<instance_id>"
    to = aws_instance.my_instance
} 
```

**Execute the terraform plan command by generating the source code**

```
terraform plan -generate_config_out=generated_resources.tf 
```

**Execute the terraform import command into the required resource, for generating the statefile**

```
terraform import aws_instance.my_instance <instance_id>
```
