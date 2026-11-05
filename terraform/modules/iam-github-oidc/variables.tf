
variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "github_repository" {
  description = "GitHub repository in owner/repository format"
  type        = string
}

variable "github_branch" {
  description = "Branch authorized to deploy to AWS"
  type        = string
  default     = "main"
}

variable "frontend_bucket_name" {
  description = "S3 bucket name used to host the frontend application"
  type        = string
}

variable "cloudfront_distribution_id" {
  description = "CloudFront distribution ID for the frontend application"
  type        = string
}

variable "aws_region" {
  description = "AWS region where the project infrastructure is deployed"
  type        = string
}
