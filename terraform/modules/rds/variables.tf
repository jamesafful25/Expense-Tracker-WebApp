
variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "private_db_subnet_ids" {
  description = "Private subnet IDs for the database"
  type        = list(string)
}

variable "rds_security_group_id" {
  description = "Security group ID assigned to RDS"
  type        = string
}

variable "db_name" {
  description = "Name of the application database"
  type        = string
}

variable "db_username" {
  description = "Master username for the database"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Initial database storage in GB"
  type        = number
  default     = 20
}

variable "db_engine_version" {
  description = "MySQL engine version"
  type        = string
  default     = "8.0.46"
}
