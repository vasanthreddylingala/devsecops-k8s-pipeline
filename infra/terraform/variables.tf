variable "region" {
  type        = string
  description = "AWS region to provision resources in"
  default     = "ap-south-1"
}

variable "my_ip_cidr" {
  type        = string
  description = "Your public IP in CIDR form, for example 203.0.113.10/32"
}

variable "public_key_path" {
  type        = string
  description = "Path to your local SSH public key"
  default     = "~/.ssh/devsecops-key.pub"
}

variable "ci_instance_type" {
  type        = string
  description = "EC2 instance type for CI/CD server (Jenkins, SonarQube, Monitoring)"
  default     = "t3.medium"
}

variable "k8s_instance_type" {
  type        = string
  description = "EC2 instance type for Kubernetes (k3s) server"
  default     = "t3.small"
}
