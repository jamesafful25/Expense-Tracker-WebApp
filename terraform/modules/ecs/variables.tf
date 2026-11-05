variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "private_app_subnet_ids" {
  description = "Private application subnet IDs for ECS tasks"
  type        = list(string)
}

variable "ecs_security_group_id" {
  description = "Security group assigned to ECS tasks"
  type        = string
}

variable "target_group_arn" {
  description = "ALB target group ARN for the backend service"
  type        = string
}

variable "ecr_repository_url" {
  description = "ECR repository URL containing the backend image"
  type        = string
}

variable "container_image_tag" {
  description = "Docker image tag to deploy"
  type        = string
  default     = "latest"
}

variable "container_port" {
  description = "Port exposed by the backend container"
  type        = number
  default     = 5000
}

variable "desired_count" {
  description = "Desired number of backend ECS tasks"
  type        = number
  default     = 0
}

variable "task_cpu" {
  description = "Fargate task CPU units"
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "Fargate task memory in MiB"
  type        = number
  default     = 512
}

variable "log_retention_days" {
  description = "CloudWatch log retention period"
  type        = number
  default     = 7
}

variable "aws_region" {
  description = "AWS region where ECS and CloudWatch resources are deployed"
  type        = string
}

variable "db_address" {
  description = "RDS database endpoint address"
  type        = string
}

variable "db_port" {
  description = "RDS database port"
  type        = number
  default     = 3306
}

variable "db_name" {
  description = "Application database name"
  type        = string
}

variable "frontend_url" {
  description = "Public URL of the frontend application"
  type        = string
}

variable "google_callback_url" {
  description = "Google OAuth callback URL"
  type        = string
}

variable "db_app_secret_arn" {
  description = "Secrets Manager ARN containing the application's database credentials"
  type        = string
}

variable "app_secrets_arn" {
  description = "Secrets Manager ARN containing JWT and Google OAuth credentials"
  type        = string
}

variable "db_master_secret_arn" {
  description = "Secrets Manager ARN containing the temporary database initialization credentials"
  type        = string
  sensitive   = true
}