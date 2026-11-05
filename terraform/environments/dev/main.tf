
module "networking" {
  source = "../../modules/networking"

  project_name = var.project_name
  environment  = var.environment

  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones

  public_subnet_cidrs      = var.public_subnet_cidrs
  private_app_subnet_cidrs = var.private_app_subnet_cidrs
  private_db_subnet_cidrs  = var.private_db_subnet_cidrs
}

module "security" {
  source = "../../modules/security"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.networking.vpc_id
  backend_port = 5000
}

# Frontend S3 Module
module "frontend" {
  source = "../../modules/frontend"

  project_name = var.project_name
  environment  = var.environment
}

# CloudFront CDN Module
module "cloudfront" {
  source = "../../modules/cloudfront"

  project_name = var.project_name
  environment  = var.environment

  frontend_bucket_id                   = module.frontend.frontend_bucket_id
  frontend_bucket_arn                  = module.frontend.frontend_bucket_arn
  frontend_bucket_regional_domain_name = module.frontend.frontend_bucket_regional_domain_name

  alb_dns_name = module.alb.alb_dns_name
}

# Amazon ECR Module
module "ecr" {
  source = "../../modules/ecr"

  project_name = var.project_name
  environment  = var.environment
}

# Application Load Balancer Module
module "alb" {
  source = "../../modules/alb"

  project_name = var.project_name
  environment  = var.environment

  vpc_id                = module.networking.vpc_id
  public_subnet_ids     = module.networking.public_subnet_ids
  alb_security_group_id = module.security.alb_security_group_id
}

# Amazon RDS MySQL Module
module "rds" {
  source = "../../modules/rds"

  project_name = var.project_name
  environment  = var.environment

  private_db_subnet_ids = module.networking.private_db_subnet_ids
  rds_security_group_id = module.security.rds_security_group_id

  db_name     = var.db_name
  db_username = var.db_username
}

# AWS Secrets Manager Module
module "secrets_manager" {
  source = "../../modules/secrets-manager"

  project_name = var.project_name
  environment  = var.environment
}

# Amazon ECS Module
module "ecs" {
  source = "../../modules/ecs"

  project_name = var.project_name
  environment  = var.environment

  private_app_subnet_ids = module.networking.private_app_subnet_ids
  ecs_security_group_id  = module.security.ecs_security_group_id

  target_group_arn   = module.alb.target_group_arn
  ecr_repository_url = module.ecr.repository_url

  container_image_tag = "latest"
  container_port      = 5000
  desired_count       = 1

  task_cpu    = 256
  task_memory = 512

  aws_region = var.aws_region

  db_address = module.rds.db_address
  db_port    = module.rds.db_port
  db_name    = module.rds.db_name

  frontend_url = "https://${module.cloudfront.cloudfront_distribution_domain_name}"

  google_callback_url = "https://${module.cloudfront.cloudfront_distribution_domain_name}/api/auth/google/callback"

  db_app_secret_arn    = module.secrets_manager.db_app_secret_arn
  app_secrets_arn      = module.secrets_manager.app_secrets_arn
  db_master_secret_arn = module.rds.db_secret_arn
}

# GitHub Actions OIDC Module
module "iam_github_oidc" {
  source = "../../modules/iam-github-oidc"

  project_name         = var.project_name
  environment          = var.environment
  github_repository    = "jamesafful25/Expense-Tracker-WebApp"
  github_owner_id      = "153740580"
  github_repository_id = "1445312232"
  github_branch        = "main"

  frontend_bucket_name       = module.frontend.frontend_bucket_id
  cloudfront_distribution_id = module.cloudfront.cloudfront_distribution_id

  aws_region = var.aws_region
}


# --------------------------------------------------
# CloudWatch Monitoring Module
# --------------------------------------------------

module "monitoring" {
  source = "../../modules/monitoring"

  project_name = var.project_name
  environment  = var.environment

  ecs_cluster_name = module.ecs.cluster_name
  ecs_service_name = module.ecs.service_name

  alb_arn_suffix          = module.alb.alb_arn_suffix
  target_group_arn_suffix = module.alb.target_group_arn_suffix

  rds_instance_id = module.rds.db_instance_id
}
