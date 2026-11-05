
variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Deployment environment, such as dev or production"
  type        = string
}

variable "frontend_bucket_id" {
  description = "Name of the private S3 frontend bucket"
  type        = string
}

variable "frontend_bucket_regional_domain_name" {
  description = "Regional domain name of the S3 frontend bucket"
  type        = string
}

variable "frontend_bucket_arn" {
  description = "ARN of the S3 frontend bucket"
  type        = string
}

variable "alb_dns_name" {
  description = "DNS name of the backend Application Load Balancer"
  type        = string
}