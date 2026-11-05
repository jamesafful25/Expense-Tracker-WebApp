# --------------------------------------------------
# Database Application Credentials Secret
# --------------------------------------------------

resource "aws_secretsmanager_secret" "db_app" {
  name        = "${var.project_name}-${var.environment}-db-app"
  description = "Application database credentials for ${var.project_name}"

  tags = {
    Name        = "${var.project_name}-${var.environment}-db-app"
    Project     = var.project_name
    Environment = var.environment
  }
}


# --------------------------------------------------
# Application Secrets
# --------------------------------------------------

resource "aws_secretsmanager_secret" "app" {
  name        = "${var.project_name}-${var.environment}-app"
  description = "JWT and Google OAuth credentials for ${var.project_name}"

  tags = {
    Name        = "${var.project_name}-${var.environment}-app"
    Project     = var.project_name
    Environment = var.environment
  }
}