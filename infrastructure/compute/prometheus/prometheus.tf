resource "aws_instance" "Prometheus" {
  ami                         = "ami-05d4121edd74a9f06"
  instance_type               = "t3.medium"
  associate_public_ip_address = true
  ipv6_address_count          = 1
  key_name                    = "Jenkins-CICD"
  security_groups             = ["sg-04cf93cbfb2b9bc0e"]

  ebs_block_device {
    device_name           = "/dev/sda1"
    volume_size           = 15
    volume_type           = "gp2"
    delete_on_termination = true
  }

  tags = {
    Name        = "Prometheus"
    Environment = "dev"
    Project     = "DevSecOps"
    Terraform   = "True"
  }

  user_data = <<-EOF
    #!/bin/bash
    set -e

    # Update package repositories and install dependencies
    sudo apt update -y
    sudo apt upgrade -y
    sudo apt install wget tar -y

    # Install Prometheus
    wget https://github.com/prometheus/prometheus/releases/download/v2.30.3/prometheus-2.30.3.linux-amd64.tar.gz
    tar -xzf prometheus-2.30.3.linux-amd64.tar.gz
    sudo cp prometheus-2.30.3.linux-amd64/{prometheus,promtool} /usr/local/bin/
    sudo cp -r prometheus-2.30.3.linux-amd64/{consoles/,console_libraries/} /usr/local/share/prometheus/

    # Create Prometheus configuration
    cat << PROMETHEUS_CONFIG | sudo tee /etc/prometheus/prometheus.yml
    global:
      scrape_interval: 15s

    scrape_configs:
      - job_name: 'prometheus'
        static_configs:
        - targets: ['localhost:9090']

    PROMETHEUS_CONFIG

    # Create Prometheus user and set permissions
    sudo useradd --no-create-home --shell /bin/false prometheus
    sudo chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus
    sudo chmod -R 775 /etc/prometheus /var/lib/prometheus

    # Create systemd service for Prometheus
    sudo tee /etc/systemd/system/prometheus.service << PROMETHEUS_SERVICE
    [Unit]
    Description=Prometheus Monitoring
    Wants=network-online.target
    After=network-online.target

    [Service]
    User=prometheus
    Group=prometheus
    Type=simple
    ExecStart=/usr/local/bin/prometheus \
      --config.file=/etc/prometheus/prometheus.yml \
      --storage.tsdb.path=/var/lib/prometheus \
      --web.console.templates=/usr/local/share/prometheus/consoles \
      --web.console.libraries=/usr/local/share/prometheus/console_libraries

    [Install]
    WantedBy=multi-user.target
    PROMETHEUS_SERVICE

    sudo systemctl daemon-reload
    sudo systemctl enable prometheus
    sudo systemctl start prometheus

    # Set hostname to Prometheus
    sudo hostnamectl set-hostname Prometheus

    # Output usernames and passwords to a file
    echo "Username: prometheus" | sudo tee /home/ubuntu/keys.txt
    echo "Password: prometheus" | sudo tee -a /home/ubuntu/keys.txt

    # Check if all steps completed successfully and remove user data
    if [ $? -eq 0 ]; then
      sudo cloud-init clean --logs --reboot
    fi
  EOF
}

resource "aws_eip" "prometheus_eip" {
  instance = aws_instance.Prometheus.id
}
