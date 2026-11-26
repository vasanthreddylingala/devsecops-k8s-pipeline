output "ci_public_ip" {
  description = "Public IP of the CI/CD server (SSH, Jenkins, SonarQube, Grafana)"
  value       = aws_instance.ci.public_ip
}

output "ci_private_ip" {
  description = "Private VPC IP of the CI/CD server"
  value       = aws_instance.ci.private_ip
}

output "k8s_public_ip" {
  description = "Public IP of the Kubernetes server (SSH and browser access)"
  value       = aws_instance.k8s.public_ip
}

output "k8s_private_ip" {
  description = "Private VPC IP of the Kubernetes server (kubeconfig, Jenkins smoke tests, Prometheus)"
  value       = aws_instance.k8s.private_ip
}
