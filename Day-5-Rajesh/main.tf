resource "aws_key_pair" "rc_kp" {
  key_name   = "terraform-keypair"  # Replace with your desired key name
  public_key = file("~/.ssh/id_rsa.pub")  # Replace with the path to your public key file
}
resource "aws_vpc" "rc_vpc" {
  cidr_block = var.cidr_vpc
}
resource "aws_subnet" "rc_subnet1" {
  vpc_id                  = aws_vpc.rc_vpc.id
  cidr_block              = var.cidr_subnet1
  availability_zone       = var.az1
  map_public_ip_on_launch = true
}
resource "aws_internet_gateway" "rc_igw" {
  vpc_id = aws_vpc.rc_vpc.id
}   
resource "aws_route_table" "rc_rt" {
  vpc_id = aws_vpc.rc_vpc.id

  route {
    cidr_block = var.cidr_internet
    gateway_id = aws_internet_gateway.rc_igw.id
  }
}
resource "aws_route_table_association" "rc_rta" {
  subnet_id      = aws_subnet.rc_subnet1.id
  route_table_id = aws_route_table.rc_rt.id
}
resource "aws_security_group" "rc_sg" {
  name   = "rcsg"
  vpc_id = aws_vpc.rc_vpc.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.cidr_internet]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.cidr_internet]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.cidr_internet]
  }

  tags = {
    Name = "rc-sg"
  }
}
resource "aws_instance" "rc_instance1" {
  ami                    = var.ami_id1
  instance_type          = var.instance_type1
  key_name               = aws_key_pair.rc_kp.key_name
  vpc_security_group_ids = [aws_security_group.rc_sg.id]
  subnet_id              = aws_subnet.rc_subnet1.id

  connection {
    type        = "ssh"
    user        = "ubuntu"  # Replace with the appropriate username for your EC2 instance
    private_key = file("~/.ssh/id_rsa")  # Replace with the path to your private key
    host        = self.public_ip
  }

  # File provisioner to copy a file from local to the remote EC2 instance
  provisioner "file" {
    source      = "app.py"  # Replace with the path to your local file
    destination = "/home/ubuntu/app.py"  # Replace with the path on the remote instance
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Hello from the remote instance'",
      "sudo apt update -y",  # Update package lists (for ubuntu)
      "sudo apt install -y python3-pip python3-flask",  # Example package installation
      "cd /home/ubuntu",
      # Create systemd service
      "echo '[Unit]' | sudo tee /etc/systemd/system/flaskapp.service",
      "echo 'Description=Flask App' | sudo tee -a /etc/systemd/system/flaskapp.service",
      "echo 'After=network.target' | sudo tee -a /etc/systemd/system/flaskapp.service",
      "echo '' | sudo tee -a /etc/systemd/system/flaskapp.service",
      "echo '[Service]' | sudo tee -a /etc/systemd/system/flaskapp.service",
      "echo 'User=root' | sudo tee -a /etc/systemd/system/flaskapp.service",
      "echo 'WorkingDirectory=/home/ubuntu' | sudo tee -a /etc/systemd/system/flaskapp.service",
      "echo 'ExecStart=/usr/bin/python3 /home/ubuntu/app.py' | sudo tee -a /etc/systemd/system/flaskapp.service",
      "echo 'Restart=always' | sudo tee -a /etc/systemd/system/flaskapp.service",
      "echo '' | sudo tee -a /etc/systemd/system/flaskapp.service",
      "echo '[Install]' | sudo tee -a /etc/systemd/system/flaskapp.service",
      "echo 'WantedBy=multi-user.target' | sudo tee -a /etc/systemd/system/flaskapp.service",

      # Enable & start service
      "sudo systemctl daemon-reload",
      "sudo systemctl enable flaskapp",
      "sudo systemctl start flaskapp"
    ]
  }
}
