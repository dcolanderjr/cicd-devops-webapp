output "sonarqube_elastic_ip" {
  value = elastic_ip.SonarQube.public_ip
}

output "sonarqube_url" {
  value = "http://${aws_instance.SonarQube.public_ip}:9000"
}
