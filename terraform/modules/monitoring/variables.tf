
variable "project_name" {
  description = "Name of the application project"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster to monitor"
  type        = string
}

variable "ecs_service_name" {
  description = "Name of the ECS backend service to monitor"
  type        = string
}

variable "alb_arn_suffix" {
  description = "ARN suffix of the Application Load Balancer"
  type        = string
}

variable "target_group_arn_suffix" {
  description = "ARN suffix of the ALB target group"
  type        = string
}

variable "rds_instance_id" {
  description = "Identifier of the RDS database instance"
  type        = string
}
