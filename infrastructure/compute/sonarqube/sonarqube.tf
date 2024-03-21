resource "aws_instance" "SonarQube" {
  ami                         = "ami-05d4121edd74a9f06"
  instance_type               = "t3.medium"
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
    Name        = "SonarQube"
  }

  user_data = <<-EOF
    #!/bin/bash
    sudo apt update -y
    sudo apt upgrade -y
    sudo apt install openjdk-17-jre -y
    
    # Install PostgreSQL
    sudo apt install postgresql postgresql-contrib -y

    # Create PostgreSQL user and database for SonarQube
    sudo -u postgres psql -c "CREATE USER sonar WITH PASSWORD 'sonar';"
    sudo -u postgres createdb -O sonar sonar

    # Install SonarQube
    sudo wget -O /usr/share/keyrings/sonarqube-keyring.gpg https://binaries.sonarsource.com/SonarSource/sqs-sonarqube/org/sonarsource/scanner/cli/sonar-scanner-cli/4.6.0.2311/sonar-scanner-cli-4.6.0.2311-linux.zip
    sudo unzip -o /usr/share/keyrings/sonarqube-keyring.gpg -d /opt
    sudo apt-get update
    sudo apt-get install apt-transport-https
    sudo echo "deb https://deb.debian.org/debian buster-backports main" | sudo tee -a /etc/apt/sources.list.d/backports.list
    sudo apt-get update
    sudo apt-get install openjdk-11-jre -y
    sudo apt-get install sonarqube -y

    # Configure SonarQube
    sudo sed -i 's/#sonar.jdbc.username=/sonar.jdbc.username=sonar/' /etc/sonarqube/sonar.properties
    sudo sed -i 's/#sonar.jdbc.password=/sonar.jdbc.password=sonar/' /etc/sonarqube/sonar.properties

    # Set vm.max_map_count kernel parameter
    sudo sysctl -w vm.max_map_count=262144
    sudo echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf

    # Start SonarQube service
    sudo systemctl enable sonarqube
    sudo systemctl start sonarqube
  EOF
}

resource "elastic_ip" "SonarQube" {
  instance = aws_instance.SonarQube.id
  vpc      = true
}
