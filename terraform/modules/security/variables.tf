
variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Deployment environment, such as dev or production"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the security groups will be created"
  type        = string
}

variable "backend_port" {
  description = "Port on which the backend application listens"
  type        = number
  default     = 5000
}
