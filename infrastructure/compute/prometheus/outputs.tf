output "prometheus_instance_id" {
  value = aws_instance.Prometheus.id
}

output "prometheus_elastic_ip" {
  value = aws_eip.prometheus_eip.public_ip
}

output "prometheus_server_url" {
  value = "http://${aws_eip.prometheus_eip.public_ip}:9090"
}
