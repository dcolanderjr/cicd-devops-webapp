resource "aws_instance" "Jenkins-Master" {
  ami                         = "ami-0c55b159cbfafe1f0"
  instance_type               = "t2.micro"
  ipv6_address_count          = 1
  key_name                    = "Jenkins-CICD"
  security_groups             = [module.sg.sg_id]
  associate_public_ip_address = true
  
  tags = {
    Environment = "dev"
    Project     = "DevSecOps"
    Terraform   = "True"
  }

user_data = <<-EOF
    #!/bin/bash
    sudo apt update -y
    sudo apt upgrade -y
    sudo apt install openjdk-17-jre -y
    sudo systemctl enable jenkins
    sudo systemctl start jenkins
    sudo hostnamectl set-hostname Jenkins-Master
    EOF
}

resource "elastic_ip" "Jenkins-Master" {
  instance = aws_instance.Jenkins-Master.id
  vpc      = true
}


