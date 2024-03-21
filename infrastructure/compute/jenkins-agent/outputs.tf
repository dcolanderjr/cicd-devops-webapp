output "jenkins_agent_instance_id" {
  value = aws_instance.Jenkins-Agent.id
}

output "jenkins_agent_elastic_ip" {
  value = elastic_ip.Jenkins-Agent.public_ip
}
