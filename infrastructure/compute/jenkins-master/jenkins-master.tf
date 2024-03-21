resource "aws_instance" "Jenkins-Master" {
  ami                         = "ami-ami-05d4121edd74a9f06"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  ipv6_address_count          = 1
  key_name                    = "Jenkins-CICD"
  security_groups             = ["sg-04cf93cbfb2b9bc0e"]

  ebs_block_device {
    device_name           = "/dev/sda1"
    volume_size           = 20
    volume_type           = "gp2"
    delete_on_termination = true
  }

  tags = {
    Environment = "dev"
    Project     = "DevSecOps"
    Terraform   = "True"
    Name        = "Jenkins-Master"
  }

  user_data = <<-EOF
    #!/bin/bash
    sudo apt update -y
    sudo apt upgrade -y
    sudo apt install openjdk-17-jre -y
    sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
    https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
    echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
    https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
    /etc/apt/sources.list.d/jenkins.list > /dev/null
    sudo apt-get update
    sudo apt-get install jenkins -y
    if [ $? -eq 0 ]; then
      echo "Jenkins installation successful"
      sudo systemctl enable jenkins
      sudo systemctl start jenkins
    else
      echo "Jenkins installation failed"
    fi
    sudo hostnamectl set-hostname Jenkins-Master
    sudo apt install docker.io -y
    sudo usermod -aG docker $USER
    sudo systemctl enable docker
    sudo systemctl start docker
    EOF
}

resource "elastic_ip" "Jenkins-Master" {
  instance = aws_instance.Jenkins-Master.id
  vpc      = true
}


