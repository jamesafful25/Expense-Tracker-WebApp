
variable "aws_region" {
  description = "AWS region for the Expense Tracker infrastructure"
  type        = string
  default     = "us-east-1"
}


variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "availability_zones" {
  description = "Availability Zones for the network"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_app_subnet_cidrs" {
  description = "CIDR blocks for private application subnets"
  type        = list(string)
}

variable "private_db_subnet_cidrs" {
  description = "CIDR blocks for private database subnets"
  type        = list(string)
}


variable "db_name" {
  description = "Name of the Expense Tracker MySQL database"
  type        = string
}

variable "db_username" {
  description = "Master username for the RDS database"
  type        = string
  sensitive   = true
}
