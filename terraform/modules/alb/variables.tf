variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Deployment environment, such as dev or production"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the load balancer will be created"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for the load balancer"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security group ID assigned to the load balancer"
  type        = string
}