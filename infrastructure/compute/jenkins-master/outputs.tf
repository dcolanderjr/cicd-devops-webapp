output "instanceID" {
  value = aws_instance.Jenkins-Master.id
}

output "jenkins_master_elastic_ip" {
  value = aws_eip.Jenkins-Master.public_ip
}

output "jenkins_service_url" {
  value = "http://${aws_eip.Jenkins-Master.public_ip}:8080"
}

